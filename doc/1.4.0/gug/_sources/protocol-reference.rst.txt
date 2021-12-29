Guacamole protocol reference
============================

Drawing instructions
--------------------

.. guac:instruction:: arc
    :sent-by: server
    :phase: interactive

    The arc instruction adds the specified arc subpath to the existing path,
    creating a new path if no path exists. The path created can be modified further
    by other path-type instructions, and finally stroked, filled, and/or closed.

    :arg integer layer:
        The layer which should have the specified arc subpath added.

    :arg integer x:
        The X coordinate of the center of the circle containing the arc to be
        drawn.

    :arg integer y:
        The Y coordinate of the center of the circle containing the arc to be
        drawn.

    :arg float radius:
        The radius of the circle containing the arc to be drawn, in pixels.

    :arg float start:
        The starting angle of the arc to be drawn, in radians.

    :arg float end:
        The ending angle of the arc to be drawn, in radians.

    :arg integer negative:
        Non-zero if the arc should be drawn from START to END in order of
        decreasing angle, zero otherwise.

.. guac:instruction:: cfill
    :sent-by: server
    :phase: interactive

    Fills the current path with the specified color. This instruction completes
    the current path. Future path instructions will begin a new path.

    :arg integer mask:
        The channel mask to apply when filling the current path in the
        specified layer.

    :arg integer layer:
        The layer whose path should be filled.

    :arg integer r:
        The red component of the color to use to fill the current path in the
        specified layer.

    :arg integer g:
        The green component of the color to use to fill the current path in the
        specified layer.

    :arg integer b:
        The blue component of the color to use to fill the current path in the
        specified layer.

    :arg integer a:
        The alpha component of the color to use to fill the current path in the
        specified layer.

.. guac:instruction:: clip
    :sent-by: server
    :phase: interactive

    Applies the current path as the clipping path. Future operations will only
    draw within the current path. Note that future clip instructions will also
    be limited by this path. To set a completely new clipping path, you must
    first reset the layer with a reset instruction. If you wish to only reset
    the clipping path, but preserve the current transform matrix, push the
    layer state before setting the clipping path, and pop the layer state to
    reset.

    :arg integer layer:
        The layer whose clipping path should be set.

.. guac:instruction:: close
    :sent-by: server
    :phase: interactive

    Closes the current path by connecting the start and end points with a
    straight line.

    :arg integer layer:
        The layer whose path should be closed.

.. guac:instruction:: copy
    :sent-by: server
    :phase: interactive

    Copies image data from the specified rectangle of the specified layer or
    buffer to a different location of another specified layer or buffer.

    :arg integer srclayer:
        The index of the layer to copy image data from.

    :arg integer srcx:
        The X coordinate of the upper-left corner of the source rectangle
        within the source layer.

    :arg integer srcy:
        The Y coordinate of the upper-left corner of the source rectangle
        within the source layer.

    :arg integer srcwidth:
        The width of the source rectangle within the source layer.

    :arg integer srcheight:
        The height of the source rectangle within the source layer.

    :arg integer mask:
        The channel mask to apply when drawing the image data on the
        destination layer.

    :arg integer dstlayer:
        The index of the layer to draw the image data to.

    :arg integer dstx:
        The X coordinate of the upper-left corner of the destination within
        the destination layer.

    :arg integer dsty:
        The Y coordinate of the upper-left corner of the destination within
        the destination layer.

.. guac:instruction:: cstroke
    :sent-by: server
    :phase: interactive

    Strokes the current path with the specified color. This instruction
    completes the current path. Future path instructions will begin a new path.

    :arg integer mask:
        The channel mask to apply when stroking the current path in the
        specified layer.

    :arg integer layer:
        The layer whose path should be stroked.

    :arg integer cap:
        The index of the line cap style to use. This can be either butt (0),
        round (1), or square (2).

    :arg integer join:
        The index of the line join style to use. This can be either bevel
        (0), miter (1), or round (2).

    :arg integer thickness:
        The thickness of the stroke to draw, in pixels.

    :arg integer r:
        The red component of the color to use to stroke the current path in
        the specified layer.

    :arg integer g:
        The green component of the color to use to stroke the current path in
        the specified layer.

    :arg integer b:
        The blue component of the color to use to stroke the current path in
        the specified layer.

    :arg integer a:
        The alpha component of the color to use to stroke the current path in
        the specified layer.

.. guac:instruction:: cursor
    :sent-by: server
    :phase: interactive

    Sets the client's cursor to the image data from the specified rectangle of
    a layer, with the specified hotspot.

    :arg integer x:
        The X coordinate of the cursor's hotspot.

    :arg integer y:
        The Y coordinate of the cursor's hotspot.

    :arg integer srclayer:
        The index of the layer to copy image data from.

    :arg integer srcx:
        The X coordinate of the upper-left corner of the source rectangle
        within the source layer.

    :arg integer srcy:
        The Y coordinate of the upper-left corner of the source rectangle
        within the source layer.

    :arg integer srcwidth:
        The width of the source rectangle within the source layer.

    :arg integer srcheight:
        The height of the source rectangle within the source layer.

.. guac:instruction:: curve
    :sent-by: server
    :phase: interactive

    Adds the specified cubic bezier curve subpath.

    :arg integer layer:
        The layer which should have the specified curve subpath added.

    :arg integer cp1x:
        The X coordinate of the first control point of the curve.

    :arg integer cp1y:
        The Y coordinate of the first control point of the curve.

    :arg integer cp2x:
        The X coordinate of the second control point of the curve.

    :arg integer cp2y:
        The Y coordinate of the second control point of the curve.

    :arg integer x:
        The X coordinate of the endpoint of the curve.

    :arg integer y:
        The Y coordinate of the endpoint of the curve.

.. guac:instruction:: dispose
    :sent-by: server
    :phase: interactive

    Removes the specified layer. The specified layer will be recreated as a new
    layer if it is referenced again.

    :arg integer layer:
        The layer to remove.

.. guac:instruction:: distort
    :sent-by: server
    :phase: interactive

    Sets the given affine transformation matrix to the layer. Unlike transform,
    this operation is independent of any previously sent transformation matrix.
    This operation can be undone by setting the layer's transformation matrix
    to the identity matrix using distort

    :arg integer layer:
        The layer to distort.

    :arg float a:
        The matrix value in row 1, column 1.

    :arg float b:
        The matrix value in row 2, column 1.

    :arg float c:
        The matrix value in row 1, column 2.

    :arg float d:
        The matrix value in row 2, column 2.

    :arg float e:
        The matrix value in row 1, column 3.

    :arg float f:
        The matrix value in row 2, column 3.

.. guac:instruction:: identity
    :sent-by: server
    :phase: interactive

    Resets the transform matrix of the specified layer to the identity matrix.

    :arg integer layer:
        The layer whose transform matrix should be reset.

.. guac:instruction:: img
    :sent-by: server
    :phase: interactive

    Allocates a new stream, associating it with the metadata of an image
    update, including the image type, the destination layer, and destination
    coordinates. The contents of the image will later be sent along the stream
    with blob instructions. The full size of the image need not be known ahead
    of time.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the image being sent.

    :arg integer mask:
        The channel mask to apply when drawing the image data.

    :arg integer layer:
        The destination layer.

    :arg integer x:
        The X coordinate of the upper-left corner of the destination within
        the destination layer.

    :arg integer y:
        The Y coordinate of the upper-left corner of the destination within
        the destination layer.

.. guac:instruction:: lfill
    :sent-by: server
    :phase: interactive

    Fills the current path with a tiled pattern of the image data from the
    specified layer. This instruction completes the current path. Future path
    instructions will begin a new path.

    :arg integer mask:
        The channel mask to apply when filling the current path in the
        specified layer.

    :arg integer layer:
        The layer whose path should be filled.

    :arg integer srclayer:
        The layer to use as the pattern.

.. guac:instruction:: line
    :sent-by: server
    :phase: interactive

    Adds the specified line subpath.

    :arg integer layer:
        The layer which should have the specified line subpath added.

    :arg integer x:
        The X coordinate of the endpoint of the line.

    :arg integer y:
        The Y coordinate of the endpoint of the line.

.. guac:instruction:: lstroke
    :sent-by: server
    :phase: interactive

    Strokes the current path with a tiled pattern of the image data from the
    specified layer. This instruction completes the current path. Future path
    instructions will begin a new path.

    :arg integer mask:
        The channel mask to apply when filling the current path in the
        specified layer.

    :arg integer layer:
        The layer whose path should be filled.

    :arg integer cap:
        The index of the line cap style to use. This can be either butt (0),
        round (1), or square (2).

    :arg integer join:
        The index of the line join style to use. This can be either bevel
        (0), miter (1), or round (2).

    :arg integer thickness:
        The thickness of the stroke to draw, in pixels.

    :arg integer srclayer:
        The layer to use as the pattern.

.. guac:instruction:: move
    :sent-by: server
    :phase: interactive

    Moves the given layer to the given location within the specified parent
    layer. This operation is applicable only to layers, and cannot be applied
    to buffers (layers with negative indices). Applying this operation to the
    default layer (layer 0) also has no effect.

    :arg integer layer:
        The layer to move.

    :arg integer parent:
        The layer that should be the parent of the given layer.

    :arg integer x:
        The X coordinate to move the layer to.

    :arg integer y:
        The Y coordinate to move the layer to.

    :arg integer z:
        The relative Z-ordering of this layer. Layers with larger values will
        appear above layers with smaller values.

.. guac:instruction:: pop
    :sent-by: server
    :phase: interactive

    Restores the previous state of the specified layer from the stack. The
    state restored includes the transformation matrix and clipping path.

    :arg integer layer:
        The layer whose state should be restored.

.. guac:instruction:: push
    :sent-by: server
    :phase: interactive

    Saves the current state of the specified layer to the stack. The state
    saved includes the current transformation matrix and clipping path.

    :arg integer layer:
        The layer whose state should be saved.

.. guac:instruction:: rect
    :sent-by: server
    :phase: interactive

    Adds a rectangular path to the specified layer.

    :arg integer mask:
        The channel mask to apply when drawing the image data.

    :arg integer layer:
        The destination layer.

    :arg integer x:
        The X coordinate of the upper-left corner of the rectangle to draw.

    :arg integer y:
        The Y coordinate of the upper-left corner of the rectangle to draw.

    :arg integer width:
        The width of the rectangle to draw.

    :arg integer height:
        The width of the rectangle to draw.

.. guac:instruction:: reset
    :sent-by: server
    :phase: interactive

    Resets the transformation and clip state of the layer.

    :arg integer layer:
        The layer whose state should be reset.

.. guac:instruction:: set
    :sent-by: server
    :phase: interactive

    Sets the given client-side property to the specified value. Currently there
    is only one property: miter-limit, the maximum distance between the inner
    and outer points of a miter joint, proportional to stroke width (if
    miter-limit is set to 10.0, the default, then the maximum distance between
    the points of the joint is 10 times the stroke width).

    :arg integer layer:
        The layer whose property should be set.

    :arg string property:
        The name of the property to set.

    :arg string value:
        The value to set the given property to.

.. guac:instruction:: shade
    :sent-by: server
    :phase: interactive

    Sets the opacity of the given layer.

    :arg integer layer:
        The layer whose opacity should be set.

    :arg integer opacity:
        The opacity of the layer, where 0 is completely transparent, and 255
        is completely opaque.

.. guac:instruction:: size
    :sent-by: server
    :phase: interactive

    Sets the size of the specified layer.

    :arg integer layer:
        The layer to resize.

    :arg integer width:
        The new width of the layer

    :arg integer height:
        The new height of the layer

.. guac:instruction:: start
    :sent-by: server
    :phase: interactive

    Starts a new subpath at the specified point.

    :arg integer layer:
        The layer which should start a new subpath.

    :arg integer x:
        The X coordinate of the first point of the new subpath.

    :arg integer y:
        The Y coordinate of the first point of the new subpath.

.. guac:instruction:: transfer
    :sent-by: server
    :phase: interactive

    Transfers image data from the specified rectangle of the specified layer or
    buffer to a different location of another specified layer or buffer, using
    the specified transfer function.

    For a list of available functions, see the definition of
    ``guac_transfer_function`` within the `guacamole/protocol-types.h
    <https://github.com/apache/guacamole-server/blob/master/src/libguac/guacamole/protocol-types.h>`__
    header included with libguac.

    :arg integer srclayer:
        The index of the layer to transfer image data from.

    :arg integer srcx:
        The X coordinate of the upper-left corner of the source rectangle
        within the source layer.

    :arg integer srcy:
        The Y coordinate of the upper-left corner of the source rectangle
        within the source layer.

    :arg integer srcwidth:
        The width of the source rectangle within the source layer.

    :arg integer srcheight:
        The height of the source rectangle within the source layer.

    :arg integer function:
        The index of the transfer function to use.

        For a list of available functions, see the definition of
        ``guac_transfer_function`` within the `guacamole/protocol-types.h
        <https://github.com/apache/guacamole-server/blob/master/src/libguac/guacamole/protocol-types.h>`__
        header included with libguac.

    :arg integer dstlayer:
        The index of the layer to draw the image data to.

    :arg integer dstx:
        The X coordinate of the upper-left corner of the destination within
        the destination layer.

    :arg integer dsty:
        The Y coordinate of the upper-left corner of the destination within
        the destination layer.

.. guac:instruction:: transform
    :sent-by: server
    :phase: interactive

    Applies the specified transformation matrix to future operations. Unlike
    distort, this operation is dependent on any previously sent transformation
    matrices, and only affects future operations. This operation can be undone
    by setting the layer's transformation matrix to the identity matrix using
    identity, but image data already drawn will not be affected.

    :arg integer layer:
        The layer to apply the given transformation matrix to.

    :arg float a:
        The matrix value in row 1, column 1.

    :arg float b:
        The matrix value in row 2, column 1.

    :arg float c:
        The matrix value in row 1, column 2.

    :arg float d:
        The matrix value in row 2, column 2.

    :arg float e:
        The matrix value in row 1, column 3.

    :arg float f:
        The matrix value in row 2, column 3.

Streaming instructions
----------------------

.. guac:instruction:: ack
    :sent-by: client,server
    :phase: interactive

    The ack instruction acknowledges a received data blob, providing a status
    code and message indicating whether the operation associated with the blob
    succeeded or failed. A status code other than 0 (``SUCCESS``) implicitly
    ends the stream.

    :arg integer stream:
        The index of the stream the corresponding blob was received on.

    :arg string message:
        A human-readable error message. This typically is not exposed within
        any user interface, and mainly helps with debugging.

    :arg integer status:
        The Guacamole status code denoting success or failure. For a list of status
        codes, see the table in `Status codes <#status-codes>`__.

.. guac:instruction:: argv
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given argument (connection
    parameter) metadata. The relevant connection parameter data will later be
    sent along the stream with blob instructions. If sent by the client, this
    data will be the desired new value of the connection parameter being
    changed, and will be applied if the server supports changing that
    connection parameter while the connection is active. If sent by the server,
    this data will be the current value of a connection parameter being exposed
    to the client.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the connection parameter being sent. In most cases,
        this will be "text/plain".

    :arg string name:
        The name of the connection parameter whose value is being sent.

.. guac:instruction:: audio
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given audio metadata.
    Audio data will later be sent along the stream with blob instructions.  The
    mimetype given must be a mimetype previously specified by the client during
    the handshake procedure. Playback will begin immediately and will continue
    as long as blobs are received along the stream.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the audio data being sent.

.. guac:instruction:: blob
    :sent-by: client,server
    :phase: interactive

    Sends a blob of data along the given stream. This blob of data is
    arbitrary, base64-encoded data, and only has meaning to the Guacamole
    client or server through the metadata assigned to the stream when the
    stream was allocated.

    :arg integer stream:
        The index of the stream along which the given data should be sent.

    :arg string data:
        The base64-encoded data to send.

.. guac:instruction:: clipboard
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given clipboard metadata.
    The clipboard data will later be sent along the stream with blob
    instructions. If sent by the client, this data will be the contents of the
    client-side clipboard. If sent by the server, this data will be the
    contents of the clipboard within the remote desktop.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the clipboard data being sent. In most cases, this
        will be "text/plain".

.. guac:instruction:: end
    :sent-by: client,server
    :phase: interactive

    The end instruction terminates an open stream, freeing any client-side or
    server-side resources. Data sent to a terminated stream will be ignored.
    Terminating a stream with the end instruction only denotes the end of the
    stream and does not imply an error.

    :arg integer stream:
        The index of the stream the corresponding blob was received on.

.. guac:instruction:: file
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given arbitrary file
    metadata. The contents of the file will later be sent along the stream with
    blob instructions. The full size of the file need not be known ahead of
    time.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the file being sent.

    :arg string filename:
        The name of the file, as it would be saved on a filesystem.

.. guac:instruction:: pipe
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given arbitrary named pipe
    metadata. The contents of the pipe will later be sent along the stream with
    blob instructions. Pipes in the Guacamole protocol are unidirectional,
    named pipes, very similar to a UNIX FIFO or pipe. It is up to client-side
    code to handle pipe data appropriately, likely based upon the name of the
    pipe, which is arbitrary. Pipes may be opened by either the client or the
    server.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the data being sent along the pipe.

    :arg string name:
        The arbitrary name of the pipe, which may have special meaning to
        client-side code.

.. guac:instruction:: video
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given video metadata.
    Video data will later be sent along the stream with blob instructions.  The
    mimetype given must be a mimetype previously specified by the client during
    the handshake procedure. Playback will begin immediately and will continue
    as long as blobs are received along the stream.

    :arg integer stream:
        The index of the stream to allocate.

    :arg integer layer:
        The index of the layer to stream the video data into. The effect of
        other drawing operations on this layer during playback is undefined,
        as the client codec implementation may leverage any rendering
        mechanism it sees fit, including hardware decoding.

    :arg string mimetype:
        The mimetype of the video data being sent.

Object instructions
-------------------

.. guac:instruction:: body
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the name of a stream previously
    requested by a get instruction. The contents of the stream will be sent
    later with blob instructions. The full size of the stream need not be known
    ahead of time.

    :arg integer object:
        The index of the object associated with this stream.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the data being sent.

    :arg string name:
        The name of the stream associated with the object.

.. guac:instruction:: filesystem
    :sent-by: server
    :phase: interactive

    Allocates a new object, associating it with the given arbitrary filesystem
    metadata. The contents of files and directories within the filesystem will
    later be sent along streams requested with get instructions or created with
    put instructions.

    :arg integer object:
        The index of the object to allocate.

    :arg string name:
        The name of the filesystem.

.. guac:instruction:: get
    :sent-by: client,server
    :phase: interactive

    Requests that a new stream be created, providing read access to the object
    stream having the given name. The requested stream will be created, in
    response, with a body instruction.

    Stream names are arbitrary and dictated by the object from which they are
    requested, with the exception of the root stream of the object itself,
    which has the reserved name "``/``". The root stream of the object has the
    mimetype "``application/vnd.glyptodon.guacamole.stream-index+json``", and
    provides a simple JSON map of available stream names to their corresponding
    mimetypes. If the object contains a hierarchy of streams, some of these
    streams may also be
    "``application/vnd.glyptodon.guacamole.stream-index+json``".

    For example, the ultimate content of the body stream provided in response
    to a get request for the root stream of an object containing two text
    streams, "A" and "B", would be the following:

    .. code-block:: json

        {
          "A" : "text/plain",
          "B" : "text/plain"
        }

    :arg integer object:
        The index of the object to request a stream from.

    :arg string name:
        The name of the stream being requested from the given object.

.. guac:instruction:: put
    :sent-by: client,server
    :phase: interactive

    Allocates a new stream, associating it with the given arbitrary object and
    stream name. The contents of the stream will later be sent with blob
    instructions.

    :arg integer object:
        The index of the object associated with this stream.

    :arg integer stream:
        The index of the stream to allocate.

    :arg string mimetype:
        The mimetype of the data being sent.

    :arg string name:
        The name of the stream within the given object to which data is being
        sent.

.. guac:instruction:: undefine
    :sent-by: client,server
    :phase: interactive

    Undefines an existing object, allowing its index to be reused by another
    future object. The resource associated with the original object may or may
    not continue to exist - it simply no longer has an associated object.

    :arg integer object:
        The index of the object to undefine.

Client handshake instructions
-----------------------------

.. guac:instruction:: audio
    :sent-by: client
    :phase: handshake 

    Specifies which audio mimetypes are supported by the client. Each parameter
    must be a single mimetype, listed in order of client preference, with the
    optimal mimetype being the first parameter.

.. guac:instruction:: connect
    :sent-by: client
    :phase: handshake 

    Begins the connection using the previously specified protocol with the
    given arguments. This is the last instruction sent during the handshake
    phase.

    The parameters of this instruction correspond exactly to the parameters of
    the received args instruction. If the received args instruction has, for
    example, three parameters, the responding connect instruction must also
    have three parameters.

.. guac:instruction:: image
    :sent-by: client
    :phase: handshake 

    Specifies which image mimetypes are supported by the client. Each parameter
    must be a single mimetype, listed in order of client preference, with the
    optimal mimetype being the first parameter.

    It is expected that the supported mimetypes will include at least
    "image/png" and "image/jpeg", and the server *may* safely assume that these
    mimetypes are supported, even if they are absent from the handshake.

.. guac:instruction:: select
    :sent-by: client
    :phase: handshake 

    Requests that the connection be made using the specified protocol, or to
    the specified existing connection. Whether a new connection is established
    or an existing connection is joined depends on whether the ID of an active
    connection is provided. The Guacamole protocol dictates that the IDs
    generated for active connections (provided during the handshake of those
    connections via the `ready instruction <#ready-instruction>`__) must not
    collide with any supported protocols.

    This is the first instruction sent during the handshake phase.

    :arg string identifier:
        The name of the protocol to use, such as "vnc" or "rdp", or the ID of
        the active connection to be joined, as returned via the `ready
        instruction <#ready-instruction>`__.

.. guac:instruction:: size
    :sent-by: client
    :phase: handshake 

    Specifies the client's optimal screen size and resolution.

    :arg integer width:
        The optimal screen width.

    :arg integer height:
        The optimal screen height.

    :arg integer dpi:
        The optimal screen resolution, in approximate DPI.

.. guac:instruction:: timezone
    :sent-by: client
    :phase: handshake 

    Specifies the timezone of the client system, in IANA zone key format.  This
    is a single-value parameter, and may be used by protocols to set the
    timezone on the remote computer, if the remote system allows the timezone
    to be configured. This instruction is optional.

    :arg string timezone:

.. guac:instruction:: video
    :sent-by: client
    :phase: handshake 

    Specifies which video mimetypes are supported by the client. Each parameter
    must be a single mimetype, listed in order of client preference, with the
    optimal mimetype being the first parameter.

Server handshake instructions
-----------------------------

.. guac:instruction:: args
    :sent-by: server
    :phase: handshake 

    Reports the expected format of the argument list for the protocol requested
    by the client. This message can be sent by the server during the handshake
    phase only.

    The first parameter of this instruction will be the protocol version
    supported by the server. This is used to negotiate protocol compatibility
    between the client and the server, with the highest supported protocol by
    both sides being chosen. Versions of Guacamole prior to 1.1.0 do not
    support protocol version negotiation, and will silently ignore this
    instruction.

    The remaining parameters of the args instruction are the names of all
    connection parameters accepted by the server for the protocol selected by
    the client, in order. The client's responding connect instruction must
    contain the values of each of these parameters in the same order.

Control instructions
--------------------

.. guac:instruction:: disconnect
    :sent-by: client,server
    :phase: handshake,interactive

    Notifies the client or server that the connection is about to be closed.
    This message can be sent during any phase, and takes no parameters.

.. guac:instruction:: nop
    :sent-by: client,server
    :phase: interactive

    The "nop" instruction does absolutely nothing, has no parameters, and is
    universally ignored by both Guacamole clients and servers. Its main use is
    as a keep-alive signal, and may be sent by guacd, client plugins, or web
    applications when there is no activity to ensure the socket is not closed
    due to timeout.

.. guac:instruction:: sync
    :sent-by: client,server
    :phase: interactive

    Reports that all operations as of the given server-relative timestamp have
    been completed. Both client and server are expected to occasionally send
    sync to report on current operation execution state, with the server using
    sync to denote the end of a logical frame.
    
    If a sync is received from the server, the client must respond with a
    corresponding sync once all previous operations have been completed, or the
    server may stop sending updates until the client catches up. For the
    client, sending a sync with a timestamp newer than any timestamp received
    from the server is an error.

    :arg integer timestamp:
        A valid server-relative timestamp.

Server control instructions
---------------------------

.. guac:instruction:: error
    :sent-by: server
    :phase: handshake,interactive

    Notifies the client that the connection is about to be closed due to the
    specified error. This message can be sent by the server during any phase.

    :arg string message:
        An arbitrary message describing the error

    :arg integer status:
        The Guacamole status code describing the error. For a list of status
        codes, see the table in `Status codes <#status-codes>`__.

.. guac:instruction:: log
    :sent-by: server
    :phase: interactive

    The log instruction sends an arbitrary string for debugging purposes.  This
    instruction will be ignored by Guacamole clients, but can be seen in
    protocol dumps if such dumps become necessary. Sending a log instruction
    can help add context when searching for the cause of a fault in protocol
    support.

    :arg string message:
        An arbitrary, human-readable message.

.. guac:instruction:: mouse
    :sent-by: server
    :phase: interactive

    Reports that a user on the current connection has moved the mouse to the
    given coordinates.

    :arg integer x:
        The current X coordinate of the mouse pointer.

    :arg integer y:
        The current Y coordinate of the mouse pointer.

.. guac:instruction:: ready
    :sent-by: server
    :phase: handshake

    The ready instruction sends the ID of a new connection and marks the
    beginning of the interactive phase of a new, successful connection. The ID
    sent is a completely arbitrary string, and has no standard format. It must
    be unique from all existing and future connections and may not match the
    name of any installed protocol support.

    :arg string identifier:
        An arbitrary, unique identifier for the current connection. This
        identifier must be unique from all existing and future connections,
        and may not match the name of any installed protocol support (such as
        "vnc" or "rdp").

Input/Event instructions
------------------------

.. guac:instruction:: key
    :sent-by: client
    :phase: interactive

    Sends the specified key press or release event.

    :arg integer keysym:
        The `X11 keysym <http://www.x.org/wiki/KeySyms>`__ of the key being
        pressed or released.

    :arg integer pressed:
        0 if the key is not pressed, 1 if the key is pressed.

.. guac:instruction:: mouse
    :sent-by: client
    :phase: interactive

    Sends the specified mouse movement or button press or release event (or
    combination thereof).

    :arg integer x:
        The current X coordinate of the mouse pointer.

    :arg integer y:
        The current Y coordinate of the mouse pointer.

    :arg integer mask:
        The button mask, representing the pressed or released status of each
        mouse button.

.. guac:instruction:: size
    :sent-by: client
    :phase: interactive

    Specifies that the client's optimal screen size has changed from what was
    specified during the handshake, or from previously-sent "size"
    instructions.

    :arg integer width:
        The new, optimal screen width.

    :arg integer height:
        The new, optimal screen height.

Status codes
------------

Several Guacamole instructions, and various other internals of the Guacamole
core, use a common set of numeric status codes. These codes denote success or
failure of operations, and can be rendered by user interfaces in a
human-readable way.

0 (``SUCCESS``)
    The operation succeeded. No error.

256 (``UNSUPPORTED``)
    The requested operation is unsupported.

512 (``SERVER_ERROR``)
    An internal error occurred, and the operation could not be performed.

513 (``SERVER_BUSY``)
    The operation could not be performed because the server is busy.

514 (``UPSTREAM_TIMEOUT``)
    The upstream server is not responding. In most cases, the upstream server
    is the remote desktop server.

515 (``UPSTREAM_ERROR``)
    The upstream server encountered an error. In most cases, the upstream
    server is the remote desktop server.

516 (``RESOURCE_NOT_FOUND``)
    An associated resource, such as a file or stream, could not be found, and
    thus the operation failed.

517 (``RESOURCE_CONFLICT``)
    A resource is already in use or locked, preventing the requested operation.

518 (``RESOURCE_CLOSED``)
    The requested operation cannot continue because the associated resource has
    been closed.

519 (``UPSTREAM_NOT_FOUND``)
    The upstream server does not appear to exist, or cannot be reached over the
    network. In most cases, the upstream server is the remote desktop server.

520 (``UPSTREAM_UNAVAILABLE``)
    The upstream server is refusing to service connections. In most cases, the
    upstream server is the remote desktop server.

521 (``SESSION_CONFLICT``)
    The session within the upstream server has ended because it conflicts with
    another session. In most cases, the upstream server is the remote desktop
    server.

522 (``SESSION_TIMEOUT``)
    The session within the upstream server has ended because it appeared to be
    inactive. In most cases, the upstream server is the remote desktop server.

523 (``SESSION_CLOSED``)
    The session within the upstream server has been forcibly closed. In most
    cases, the upstream server is the remote desktop server.

768 (``CLIENT_BAD_REQUEST``)
    The parameters of the request are illegal or otherwise invalid.

769 (``CLIENT_UNAUTHORIZED``)
    Permission was denied, because the user is not logged in. Note that the
    user may be logged into Guacamole, but still not logged in with respect to
    the remote desktop server.

771 (``CLIENT_FORBIDDEN``)
    Permission was denied, and logging in will not solve the problem.

776 (``CLIENT_TIMEOUT``)
    The client (usually the user of Guacamole or their browser) is taking too
    long to respond.

781 (``CLIENT_OVERRUN``)
    The client has sent more data than the protocol allows.

783 (``CLIENT_BAD_TYPE``)
    The client has sent data of an unexpected or illegal type.

797 (``CLIENT_TOO_MANY``)
    The client is already using too many resources. Existing resources must be
    freed before further requests are allowed.

