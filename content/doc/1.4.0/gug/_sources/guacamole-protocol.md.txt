The Guacamole protocol
======================

This chapter is an overview of the Guacamole protocol, describing its design
and general use. While a few instructions and their syntax will be described
here, this is not an exhaustive list of all available instructions. The intent
is only to list the general types and usage. If you are looking for the syntax
or purpose of a specific instruction, consult the protocol reference included
with the appendices.

(guacamole-protocol-design)=

Design
------

The Guacamole protocol consists of instructions. Each instruction is a
comma-delimited list followed by a terminating semicolon, where the first
element of the list is the instruction opcode, and all following elements are
the arguments for that instruction:

```
OPCODE,ARG1,ARG2,ARG3,...;
```

Each element of the list has a positive decimal integer length prefix separated
by the value of the element by a period. This length denotes the number of
Unicode characters in the value of the element, which is encoded in UTF-8:

```
LENGTH.VALUE
```

Any number of complete instructions make up a message which is sent from client
to server or from server to client. Client to server instructions are generally
control instructions (for connecting or disconnecting) and events (mouse and
keyboard). Server to client instructions are generally drawing instructions
(caching, clipping, drawing images), using the client as a remote display.

For example, a complete and valid instruction for setting the display size to
1024x768 would be:

```
4.size,1.0,4.1024,3.768;
```

Here, the instruction would be decoded into four elements: "size", the opcode
of the size instruction, "0", the index of the default layer, "1024", the
desired width in pixels, and "768", the desired height in pixels.

The structure of the Guacamole protocol is important as it allows the protocol
to be streamed while also being easily parsable by JavaScript.  JavaScript does
have native support for conceptually-similar structures like XML or JSON, but
neither of those formats is natively supported in a way that can be streamed;
JavaScript requires the entirety of the XML or JSON message to be available at
the time of decoding. The Guacamole protocol, on the other hand, can be parsed
as it is received, and the presence of length prefixes within each instruction
element means that the parser can quickly skip around from instruction to
instruction without having to iterate over every character.

(guacamole-protocol-handshake)=

Handshake phase
---------------

The handshake phase is the phase of the protocol entered immediately upon
connection. It begins with a "select" instruction sent by the client which
tells the server which protocol will be loaded:

```
6.select,3.vnc;
```

After receiving the "select" instruction, the server will load the associated
client support and respond with its protocol version and a list of accepted
parameter names using an "args" instruction:

```
4.args,13.VERSION_1_1_0,8.hostname,4.port,8.password,13.swap-red-blue,9.read-only;
```

The protocol version is used to negotiate compatibility between differing
versions of client and server, allowing the two sides to negotiate the highest
supported version and enable or disable features associated with that version.
Older implementations of the Guacamole protocol that do not support version
negotiation will silently ignore it as if it were an unspecified connection
parameter.

Valid protocol versions are as follows:

`VERSION_1_3_0`
: Protocol version 1.3.0 introduced the `require` instruction, used by the
  server to indicate that the client must provide additional arguments (such
  as a username and password).

`VERSION_1_1_0`
: Protocol version 1.1.0 introduced support for protocol version
  negotiation, arbitrary order of the handshake instructions, and support
  for passing the timezone instruction during the handshake.

`VERSION_1_0_0`
: This is the default version and applies to any versions prior to 1.1.0.
  Version 1.0.0 of the protocol does not support protocol negotiation, and
  requires that the handshake instructions are delivered in a certain order,
  and that they are present (even if empty).

After receiving the list of arguments, the client is required to respond with
the list of supported audio, video, and image mimetypes, the optimal display
size and resolution, and the values for all arguments available, even if blank.

```
4.size,4.1024,3.768,2.96;
5.audio,9.audio/ogg;
5.video;
5.image,9.image/png,10.image/jpeg;
8.timezone,16.America/New_York;
7.connect,13.VERSION_1_1_0,9.localhost,4.5900,0.,0.,0.;
```

For clarity, we've put each instruction on its own line, but in the real
protocol, no newlines exist between instructions. In fact, if there is anything
after an instruction other than the start of a new instruction, the connection
is closed.

The following are valid instructions during the handshake:

`audio`
: The audio codec(s) supported by the client. In the example above the
  client is specifying audio/ogg as the supported codec.

`connect`
: This is the final instruction of the handshake, terminating the handshake
  and indicating that the connection should continue. This instruction has
  as its parameters values for the connection parameters sent by the server
  in the `args` instruction. In the example above, this is connection to
  localhost on port 5900, with no values for the last three connection
  parameters.

`image`
: The image formats that the client supports, in order of preference. The
  client in the example above is supporting both PNG and JPEG.

`timezone`
: The timezone of the client, in IANA zone key format. More information on
  this instruction is available in [](configuring-guacamole), under
  documentation related to the `timezone` connection parameters for the
  protocols that support it.

`video`
: The video codec(s) supported by the client. The above example is a client
  that does not support any video codecs.

The order of the instructions sent by the client in the handshake is arbitrary,
with the exception that the final instruction, connect, will end the handshake
and attempt to start the connection.

Once these instructions have been sent by the client, the server will attempt
to initialize the connection with the parameters received and, if successful,
respond with a "ready" instruction. This instruction contains the ID of the new
client connection and marks the beginning of the interactive phase. The ID is
an arbitrary string, but is guaranteed to be unique from all other active
connections, as well as from the names of all supported protocols:

```
5.ready,37.$260d01da-779b-4ee9-afc1-c16bae885cc7;
```

The actual interactive phase begins immediately after the "ready" instruction
is sent. Drawing and event instructions pass back and forth until the
connection is closed.

(guacamole-protocol-joining)=

### Joining an existing connection

Once the handshake phase has completed, that connection is considered active
and can be joined by other connections if the ID is provided instead of a
protocol name via the "select" instruction:

```
6.select,37.$260d01da-779b-4ee9-afc1-c16bae885cc7;
```

The rest of the handshake phase for a joining connection is identical. Just as
with a new connection, the restrictions or features which apply to the joining
connection are dictated by the parameter values supplied during the handshake.

(guacamole-protocol-drawing)=

Drawing
-------

(guacamole-protocol-compositing)=

### Compositing

The Guacamole protocol provides compositing operations through the use of
"channel masks". The term "channel mask" is simply a description of the
mechanism used while designing the protocol to conceptualize and fully
enumerate all possible compositing operations based on four different sources
of image data: source image data where the destination is opaque, source image
data where the destination is transparent, destination image data where the
source is opaque, and destination image data where the source is transparent.
Assigning a binary value to each of these "channels" creates a unique integer
ID for every possible compositing operation, where these operations parallel
the operations described by Porter and Duff in their paper. As the HTML5 canvas
tag also uses Porter/Duff to describe their compositing operations (as do other
graphical APIs), the Guacamole protocol is conveniently similar to the
compositing support already present in web browsers, with some operations not
yet supported. The following operations are all implemented and known to work
correctly in all browsers:

B out A (0x02)
: Clears the destination where the source is opaque, but otherwise draws
  nothing. This is useful for masking.

A atop B (0x06)
: Fills with the source where the destination is opaque only.

A xor B (0x0A)
: As with logical XOR. Note that this is a compositing operation, not a
  bitwise operation. It draws the source where the destination is
  transparent, and draws the destination where the source is transparent.

B over A (0x0B)
: What you would typically expect when drawing, but reversed. The source
  appears only where the destination is transparent, as if you were
  attempting to draw the destination over the source, rather than the source
  over the destination.

A over B (0x0E)
: The most common and sensible compositing operation, this draws the source
  everywhere, but includes the destination where the source is transparent.

A + B (0x0F)
: Simply adds the components of the source image to the destination image,
  capping the result at pure white.

The following operations are all implemented, but may work incorrectly in
WebKit browsers which always include the destination image where the source is
transparent:

B in A (0x01)
: Draws the destination only where the source is opaque, clearing anywhere
  the source or destination are transparent.

A in B (0x04)
: Draws the source only where the destination is opaque, clearing anywhere
  the source or destination are transparent.

A out B (0x08)
: Draws the source only where the destination is transparent, clearing
  anywhere the source or destination are opaque.

B atop A (0x09)
: Fills with the destination where the source is opaque only.

A (0x0C)
: Fills with the source, ignoring the destination entirely.

The following operations are defined, but not implemented, and do not exist as
operations within the HTML5 canvas:

Clear (0x00)
: Clears all existing image data in the destination.

B (0x03)
: Does nothing.

A xnor B (0x05)
: Adds the source to the destination where the destination or source are
  opaque, clearing anywhere the source or destination are transparent. This
  is similar to A + B except the aspect of transparency is also additive.

(A + B) atop B (0x07)
: Adds the source to the destination where the destination is opaque,
  preserving the destination otherwise.

(A + B) atop A (0x0D)
: Adds the destination to the source where the source is opaque, copying the
  source otherwise.

(guacamole-protocol-images)=

### Image data

The Guacamole protocol, like many remote desktop protocols, provides a method
of sending an arbitrary rectangle of image data and placing it either within a
buffer or in a visible rectangle of the screen. Raw image data in the Guacamole
protocol is streamed as PNG, JPEG, or WebP data over a stream allocated with
the "img" instruction. Depending on the format used, image updates sent in this
manner can be RGB or RGBA (alpha transparency) and are automatically palettized
if sent using libguac. The streaming system used for image data is generalized
and used by Guacamole for other types of streams, including audio and file
transfer. For more information about streams in the Guacamole protocol, see
[](guacamole-protocol-streaming).

Image data can be sent to any specified rectangle within a layer or buffer.
Sending the data to a layer means that the image becomes immediately visible,
while sending the data to a buffer allows that data to be reused later.

(guacamole-protocol-copying-images)=

### Copying image data between layers

Image data can be copied from one layer or buffer into another layer or buffer.
This is often used for scrolling (where most of the result of the graphical
update is identical to the previous state) or for caching parts of an image.

Both VNC and RDP provide a means of copying a region of screen data and placing
it somewhere else within the same screen. RDP provides an additional means of
copying data to a cache, or recalling data from that cache and placing it on
the screen. Guacamole takes this concept and reduces it further, as both
on-screen and off-screen image storage is the same. The Guacamole "copy"
instruction allows you to copy a rectangle of image data, and place it within
another layer, whether that layer is the same as the source layer, a different
visible layer, or an off-screen buffer.

(guacamole-graphical-primitives)=

### Graphical primitives

The Guacamole protocol provides basic graphics operations similar to those of
Cairo or the HTML5 canvas. In many cases, these primitives are useful for
remote drawing, and desirable in that they take up less bandwidth than sending
corresponding PNG images. Beware that excessive use of primitives leads to an
increase in client-side processing, which may reduce the performance of a
connected client, especially if that client is on a lower-performance machine
like a mobile phone or tablet.

(guacamole-protocol-layers)=

### Buffers and layers

All drawing operations in the Guacamole protocol affect a layer, and each layer
has an integer index which identifies it. When this integer is negative, the
layer is not visible, and can be used for storage or caching of image data. In
this case, the layer is referred to within the code and within documentation as
a "buffer". Layers are created automatically when they are first referenced in
an instruction.

There is one main layer which is always present called the "default layer".
This layer has an index of 0. Resizing this layer resizes the entire remote
display. Other layers default to the size of the default layer upon creation,
while buffers are always created with a size of 0x0, automatically resizing
themselves to fit their contents.

Non-buffer layers can be moved and nested within each other. In this way,
layers provide a simple means of hardware-accelerated compositing.  If you need
a window to appear above others, or you have some object which will be moving
or you need the data beneath it automatically preserved, a layer is a good way
of accomplishing this. If a layer is nested within another layer, its position
is relative to that of its parent. When the parent is moved or reordered, the
child moves with it.  If the child extends beyond the parents bounds, it will
be clipped.

(guacamole-protocol-streaming)=

Streams and objects
-------------------

Guacamole supports transfer of clipboard contents, audio, video, and image
data, as well as files and arbitrary named pipes.

Streams are allocated directly with instructions that associate the new stream
with particular semantics and metadata, such as the "audio" or "video"
instructions used for playing media, the "file" instruction used for file
transfer, and the "pipe" instruction for transfer of completely arbitrary data
between client and server. In some cases, the availability and semantics of
streams may be explicitly advertised using structured sets of named streams
known as "objects".

Once a stream is allocated, data is sent along the stream in chunks using
"blob" instructions, which may be acknowledged by the receiving end by "ack"
instructions. The end of the stream is finally signalled with an "end"
instruction.

(guacamole-protocol-events)=

Events
------

When something changes on either side, client or server, such as a key being
pressed, the mouse moving, or clipboard data changing, an instruction
describing the event is sent.

(guacamole-protocol-disconnecting)=

Disconnecting
-------------

The server and client can end the connection at any time. There is no
requirement for the server or the client to communicate that the connection
needs to terminate. When the client or server wish to end the connection, and
the reason is known, they can use the "disconnect" or "error" instructions.

The disconnect instruction is sent by the client when it is disconnecting. This
is largely out of politeness, and the server must be written knowing that the
disconnect instruction may not always be sent in time (guacd is written this
way).

If the client does something wrong, or the server detects a problem with the
client plugin, the server sends an error instruction, including a description
of the problem in the parameters. This informs the client that the connection
is being closed.

