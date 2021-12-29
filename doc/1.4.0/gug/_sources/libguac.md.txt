libguac
=======

The C API for extending and developing with Guacamole is libguac. All native
components produced by the Guacamole project link with this library, and this
library provides the common basis for extending the native functionality of
those native components (by implementing client plugins).

libguac is used mainly for developing client plugins like libguac-client-vnc or
libguac-client-rdp, or for developing a proxy supporting the Guacamole protocol
like guacd. This chapter is intended to give an overview of how libguac is
used, and how to use it for general communication with the Guacamole protocol.

(libguac-error-handling)=

Error handling
--------------

Most functions within libguac handle errors by returning a zero or non-zero
value, whichever is appropriate for the function at hand. If an error is
encountered, the `guac_error` variable is set appropriately, and
`guac_error_message` contains a statically-allocated human-readable string
describing the context of the error. These variables intentionally mimic the
functionality provided by `errno` and `errno.h`.

Both `guac_error` and `guac_error_message` are defined within `error.h`. A
human-readable string describing the error indicated by `guac_error` can be
retrieved using `guac_status_string()`, which is also statically allocated.

If functions defined within client plugins set `guac_error` and
`guac_error_message` appropriately when errors are encountered, the messages
logged to syslog by guacd will be more meaningful for both users and
developers.

(libguac-client-plugins)=

Client plugins
--------------

Client plugins are libraries which follow specific conventions such that they
can be loaded dynamically by guacd. All client plugins *must*:

1. Follow a naming convention, where the name of the library is
   {samp}`libguac-client-{PROTOCOL}`. *This is necessary for guacd to locate
   the library for a requested protocol.*

2. Be linked against libguac, the library used by guacd to handle the Guacamole
   protocol. The structures which are given to functions invoked by guacd are
   defined by libguac, and are expected to be manipulated via the functions
   provided by libguac or as otherwise documented within the structure itself.
   *Communication between guacd and client plugins is only possible if they
   share the same core structural and functional definitions provided by
   libguac.*

3. Implement the standard entry point for client plugins, `guac_client_init()`,
   described in more detail below. It is this function which initializes the
   structures provided by guacd such that users can join and interact with the
   connection.

(libguac-lifecycle-entry)=

### Entry point

All client plugins must provide a function named `guac_client_init` which
accepts, as its sole argument, a pointer to a `guac_client` structure.  This
function is similar in principle to the main() function of a C program, and it
is the responsibility of this function to initialize the provided structure as
necessary to begin the actual remote desktop connection, allow users to
join/leave, etc.

The provided `guac_client` will already have been initialized with handlers for
logging, the broadcast socket, etc. The absolutely critical pieces which must
be provided by `guac_client_init` are:

1. A handler for users which join the connection (`join_handler`). The join
   handler is also usually the most appropriate place for the actual remote
   desktop connection to be established.

2. A `NULL`-terminated set of argument names which the client plugin accepts,
   assigned to the args property of the given `guac_client`.  As the handshake
   procedure is completed for each connecting user, these argument names will
   be presented as part of the handshake, and the values for those arguments
   will be passed to the join handler once the handshake completes.

3. A handler for users leaving the connection (`leave_handler`), if any
   cleanup, updates, etc. are required.

4. A handler for freeing the data associated with the `guac_client` after the
   connection has terminated (`free_handler`). If your plugin will allocate any
   data at all, implementing the free handler is necessary to avoid memory leaks.

If `guac_client_init` returns successfully, guacd will proceed with allowing
the first use to join the connection, and the rest of the plugin lifecycle
commences.

(libguac-lifecycle-users)=

### Joining/leaving a connection

Whenever a user joins a connection, including the very first user of a
connection (the user which is establishing the remote desktop connection in the
first place), the join handler of the `guac_client` will be invoked. This
handler is provided with the `guac_user` structure representing the user that
just joined, along with the arguments provided during the handshake procedure:

```c
int join_handler(guac_user* user, int argc, char** argv) {
    /* Synchronize display state, init the user, etc. */
}

...

/* Within guac_client_init  */
client->join_handler = join_handler;
```

As the parameters and user information provided during the Guacamole protocol
handshake are often required to be known before the remote desktop connection
can be established, the join handler is usually the best place to create a
thread which establishes the remote desktop connection and updates the display
accordingly.

If necessary, the user which first established the connection can be
distinguished from all other users by the owner flag of `guac_user`, which will
be set to a non-zero value.

Once a user has disconnected, the leave handler of `guac_client` will be
invoked. Just as with the join handler, this handler is provided the
`guac_user` structure of the user that disconnected. The `guac_user` structure
will be freed immediately after the handler completes:

```c
int leave_handler(guac_user* user) {
    /* Free user-specific data and clean up */
}

...

/* Within guac_client_init  */
client->leave_handler = leave_handler;
```

(libguac-lifecycle-termination)=

### Termination

Once the last user of a connection has left, guacd will begin freeing resources
allocated to that connection, invoking the free handler of the `guac_client`.
At this point, the "leave" handler has been invoked for all previous users. All
that remains is for the client plugin to free any remaining data that it
allocated, such that guacd can clean up the rest:

```c
int free_handler(guac_client* client) {
    /* Disconnect, free client-specific data, etc. */
}

...

/* Within guac_client_init  */
client->free_handler = free_handler;
```

(libguac-layers)=

Layers and buffers
------------------

The main operand of all drawing instructions is the layer, represented within
libguac by the `guac_layer` structure. Each `guac_layer` is normally allocated
using `guac_client_alloc_layer()` or `guac_client_alloc_buffer()`, depending on
whether a layer or buffer is desired, and freed with `guac_client_free_layer()`
or `guac_client_free_buffer()`.

:::{important}
Care must be taken to invoke the allocate and free pairs of each type of layer
correctly. `guac_client_free_layer()` should only be used to free layers
allocated with `guac_client_alloc_layer()`, and `guac_client_free_buffer()`
should only be used to free layers allocated with `guac_client_alloc_buffer()`,
all called using the same instance of `guac_client`.

If these restrictions are not observed, the effect of invoking these functions
is undefined.
:::

Using these layer management functions allows you to reuse existing layers or
buffers after their original purpose has expired, thus conserving resources on
the client side, as allocation of new layers within the remote client is a
relatively expensive operation.

It is through layers and buffers that Guacamole provides support for
hardware-accelerated compositing and cached updates. Creative use of layers and
buffers leads to efficient updates on the client side, which usually translates
into speed and responsiveness.

Regardless of whether you allocate new layers or buffers, there is always one
layer guaranteed to be present: the default layer, represented by libguac as
`GUAC_DEFAULT_LAYER`. If you only wish to affect the main display of the
connected client somehow, this is the layer you want to use as the operand of
your drawing instruction.

(libguac-streams)=

Streams
-------

In addition to drawing, the Guacamole protocol supports streaming of arbitrary
data. The main operand of all streaming instructions is the stream, represented
within libguac by the `guac_stream` structure.  Each `guac_stream` exists
either at the user or client levels, depending on whether the stream is
intended to be broadcast to all users or just one, and is thus allocated using
either `guac_client_alloc_stream()` or `guac_user_alloc_stream()`.
Explicitly-allocated streams must eventually be freed with
`guac_client_free_stream()` or `guac_user_free_stream()`.

:::{important}
Just as with layers, care must be taken to invoke the allocate and free pairs
correctly for each explicitly-allocated stream.  `guac_client_free_stream()`
should only be used to free streams allocated with
`guac_client_alloc_stream()`, and `guac_user_free_stream()` should only be used
to free streams allocated with `guac_user_alloc_stream()`.

If these restrictions are not observed, the effect of invoking these functions
is undefined.
:::

Streams are the means by which data is transmitted for clipboard (via the
["clipboard" instruction](clipboard-instruction)), audio (via the ["audio"
instruction](audio-instruction)), and even the images which make up typical
drawing operations (via the ["img" instruction](img-instruction)). They will
either be allocated for you, when an inbound stream is received from a user, or
allocated manually, when an outbound stream needs to be sent to a user. As with
`guac_client` and `guac_user`, each `guac_stream` has a set of handlers which
correspond to instructions received related to streams.  These instructions are
documented in more detail in [](guacamole-protocol-streaming) and
[](protocol-reference).

(libguac-sending-instructions)=

Sending instructions
--------------------

All drawing in Guacamole is accomplished through the sending of instructions to
the connected client using the Guacamole protocol. The same goes for streaming
audio, video, or file content. All features and content supported by Guacamole
ultimately reduce to one or more instructions which are part of the documented
protocol.

Most drawing using libguac is done using Cairo functions on a `cairo_surface_t`
(see the Cairo API documentation) which is later streamed to the client using
an img instruction and subsequent blob instructions, sent via
`guac_client_stream_png()`. Cairo was chosen as a dependency of libguac to
provide developers an existing and stable means of drawing to image buffers
which will ultimately be sent as easy-to-digest PNG images.

The Guacamole protocol also supports drawing primitives similar to those
present in the Cairo API and HTML5's canvas tag. These instructions are
documented individually in the Guacamole Protocol Reference in a section
dedicated to drawing instructions, and like all Guacamole protocol
instructions, each instruction has a corresponding function in libguac
following the naming convention {samp}`guac_protocol_send_{OPCODE}()`.

Each protocol function takes a `guac_socket` as an argument, which is the
buffered I/O object used by libguac. For each active connection, there are two
important types of `guac_socket` instance: the broadcast socket, which exists
at the client level within the `guac_client`, and the per-user socket, which is
accessible within each `guac_user`. Data sent along the client-level broadcast
socket will be sent to all connected users beneath that `guac_client`, while
data sent along a user-level socket will be sent only to that user.

For example, to send a "size" instruction to all connected users via the
client-level broadcast socket, you could invoke:

```c
guac_protocol_send_size(client->socket, GUAC_DEFAULT_LAYER, 1024, 768);
```

Or, if the instruction is only relevant to a particular user, the socket
associated with that user can be used instead:

```c
guac_protocol_send_size(user->socket, GUAC_DEFAULT_LAYER, 1024, 768);
```

The sockets provided by libguac are threadsafe at the protocol level.
Instructions written to a socket by multiple threads are guaranteed to be
written atomically with respect to that socket.

(libguac-event-handling)=

Event handling
--------------

Generally, as guacd receives instructions from the connected client, it invokes
event handlers if set within the associated `guac_user` or `guac_client`,
depending on the nature of the event. Most events are user-specific, and thus
the event handlers reside within the `guac_user` structure, but there are
client-specific events as well, such as a user joining or leaving the current
connection. Event handlers typically correspond to Guacamole protocol
instructions received over the socket by a connected user, which in turn
correspond to events which occur on the client side.

(libguac-key-events)=

### Key events

When keys are pressed or released on the client side, the client sends key
instructions to the server. These instructions are parsed and handled by
calling the key event handler installed in the `key_handler` member of the
`guac_user`. This key handler is given the keysym of the key that was changed,
and a boolean value indicating whether the key was pressed or released.

```c
int key_handler(guac_user* user, int keysym, int pressed) {
    /* Do something */
}

...

/* Within the "join" handler of guac_client */
user->key_handler = key_handler;
```

(libguac-mouse-events)=

### Mouse events

When the mouse is moved, and buttons are pressed or released, the client sends
mouse instructions to the server. These instructions are parsed and handled by
calling the mouse event handler installed in the `mouse_handler` member of the
`guac_user`. This mouse handler is given the current X and Y coordinates of the
mouse pointer, as well as a mask indicating which buttons are pressed and which
are released.

```c
int mouse_handler(guac_user* user, int x, int y, int button_mask) {
    /* Do something */
}

...

/* Within the "join" handler of guac_client */
user->mouse_handler = mouse_handler;
```

The file `client.h` also defines the mask of each button for convenience:

`GUAC_CLIENT_MOUSE_LEFT`
: The left mouse button, set when pressed.

`GUAC_CLIENT_MOUSE_MIDDLE`
: The middle mouse button, set when pressed.

`GUAC_CLIENT_MOUSE_RIGHT`
: The right mouse button, set when pressed.

`GUAC_CLIENT_MOUSE_UP`
: The button corresponding to one scroll in the upwards direction of the mouse
  scroll wheel, set when scrolled.

`GUAC_CLIENT_MOUSE_DOWN`
: The button corresponding to one scroll in the downwards direction of the
  mouse scroll wheel, set when scrolled.

(libguac-clipboard-events)=

### Clipboard, file, and other stream events

If a connected user sends data which should be sent to the clipboard of the
remote desktop, guacd will trigger the clipboard handler installed in the
`clipboard_handler` member of the `guac_user` associated with that user.

```c
int clipboard_handler(guac_user* user, guac_stream* stream, char* mimetype) {
    /* Do something */
}

...

/* Within the "join" handler of guac_client */
user->clipboard_handler = clipboard_handler;
```

The handler is expected to assign further handlers to the provided
`guac_stream` as necessary, such that the ["blob"](blob-instruction) and
["end"](end-instruction) instructions received along the stream can be handled.
A similar handler is provided for received files:

```c
int file_handler(guac_user* user, guac_stream* stream,
        char* mimetype, char* filename) {
    /* Do something */
}

...

/* Within the "join" handler of guac_client */
user->file_handler = file_handler;
```

This pattern continues for all other types of streams which can be received
from a user. The instruction which begins the stream has a corresponding
handler within `guac_user`, and the metadata describing that stream and
provided with the instruction is included within the parameters passed to that
handler.

These handlers are, of course, optional. If any type of stream lacks a
corresponding handler, guacd will automatically close the stream and respond
with an ["ack" instruction](ack-instruction) and appropriate error code,
informing the user's Guacamole client that the stream is unsupported.

