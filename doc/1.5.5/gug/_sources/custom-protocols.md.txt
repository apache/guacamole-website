Adding new protocols
====================

Guacamole's support for multiple remote desktop protocols is provided through
plugins which guacd loads dynamically. The Guacamole API has been designed such
that protocol support is easy to create, especially when a C library exists
providing a basic client implementation.

In this tutorial, we will implement a simple "client" which renders a bouncing
ball using the Guacamole protocol. After completing the tutorial and installing
the result, you will be able to add a connection to your Guacamole
configuration using the "ball" protocol, and any users using that connection
will see a bouncing ball.

This example client plugin doesn't actually act as a client, but this isn't
important. The Guacamole client is really just a remote display, and this
client plugin functions as a simple example application which renders to this
display, just as Guacamole's own VNC or RDP plugins function as VNC or RDP
clients which render to the remote display.

Each step of this tutorial is intended to exercise a new concept, while also
progressing towards the goal of a nifty bouncing ball. At the end of each step,
you will have a buildable and working client plugin.

This tutorial will use the GNU Automake build system, which is the build system
used by Guacamole for libguac, guacd, etc. There will be four files involved:

`configure.ac`
: Used by GNU Automake to generate the `configure` script which ultimately
  serves to generate the `Makefile` which {command}`make` will use when
  building.

`Makefile.am`
: Used by GNU Automake and the `configure` script to generate the `Makefile`
  which {command}`make` will use when building.

`src/ball.c`
: The main body of code defining the bouncing ball "client".

`src/ball.h`
: A header file defining the structure representing the state of the bouncing
  ball (once it becomes necessary to do so).

All source files will be within the `src` subdirectory, as is common with C
projects, with build files being at the root level directory. The main
`src/ball.c` and the build-related `configure.ac` and `Makefile.am` files will
be created first, with each successive step building upon those files
iteratively, with `src/ball.h` being added when it becomes necessary. After
each step, you can build/rebuild the plugin by running {command}`make`, and
then install it (such that guacd can find the plugin) by running {command}`make
install` and {command}`ldconfig` as root:

```console
$ make
  CC       src/ball.lo
  CCLD     libguac-client-ball.la
# make install
make[1]: Entering directory '/home/user/libguac-client-ball'
 /usr/bin/mkdir -p '/usr/local/lib'
 /bin/sh ./libtool   --mode=install /usr/bin/install -c   libguac-client-ball.la '/usr/local/lib'
...
----------------------------------------------------------------------
Libraries have been installed in:
   /usr/local/lib

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the '-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the 'LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the 'LD_RUN_PATH' environment variable
     during linking
   - use the '-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to '/etc/ld.so.conf'

See any operating system documentation about shared libraries for
more information, such as the ld(1) and ld.so(8) manual pages.
----------------------------------------------------------------------
make[1]: Nothing to be done for 'install-data-am'.
make[1]: Leaving directory '/home/user/libguac-client-ball'
# ldconfig
```

Prior to the first time {command}`make` is invoked, you will need to run the
`configure` script, which will first need to be generated using
{command}`autoreconf`:

```console
$ autoreconf -fi
libtoolize: putting auxiliary files in '.'.
libtoolize: copying file './ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIRS, 'm4'.
libtoolize: copying file 'm4/libtool.m4'
libtoolize: copying file 'm4/ltoptions.m4'
libtoolize: copying file 'm4/ltsugar.m4'
libtoolize: copying file 'm4/ltversion.m4'
libtoolize: copying file 'm4/lt~obsolete.m4'
configure.ac:10: installing './compile'
configure.ac:4: installing './missing'
Makefile.am: installing './depcomp'
$ ./configure
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
...
configure: creating ./config.status
config.status: creating Makefile
config.status: executing depfiles commands
config.status: executing libtool commands
$
```

This process is almost identical to that of building guacamole-server from git,
as documented in [](building-guacamole-server).

:::{important}
The libguac library which is part of guacamole-server is a required dependency
of this project. *You must first install libguac, guacd, etc. by [building and
installing guacamole-server](building-guacamole-server)*. If guacamole-server
has not been installed, and libguac is thus not present, the `configure` script
will fail with an error indicating that it could not find libguac:

```console
$ ./configure
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
...
checking for guac_client_stream_png in -lguac... no
configure: error: "libguac is required for communication via "
                   "the Guacamole protocol"
$
```

You will need to install guacamole-server and then rerun `configure`.
:::

(libguac-client-ball-skeleton)=

Minimal skeleton client
-----------------------

Very little needs to be done to implement the most basic client plugin
possible. We begin with `src/ball.c`, containing the absolute minimum required
for a client plugin:

```c
#include <guacamole/client.h>

#include <stdlib.h>

/* Client plugin arguments (empty) */
const char* TUTORIAL_ARGS[] = { NULL };

int guac_client_init(guac_client* client) {

    /* This example does not implement any arguments */
    client->args = TUTORIAL_ARGS;

    return 0;

}
```

Notice the structure of this file. There is exactly one function,
`guac_client_init`, which is the entry point for all Guacamole client plugins.
Just as a typical C program has a main function which is executed when the
program is run, a Guacamole client plugin has `guac_client_init` which is
called when guacd loads the plugin when a new connection is made and your
protocol is selected.

`guac_client_init` receives a single `guac_client` which it must initialize.
Part of this initialization process involves declaring the list of arguments
that joining users can specify. While we won't be using arguments in this
tutorial, and thus the arguments assigned above are simply an empty list, a
typical client plugin implementation would register arguments which define the
remote desktop connection and its behavior. Examples of such parameters can be
seen in the connection parameters for the protocols supported by Guacamole
out-of-the-box (see [](connection-configuration)).

The `guac_client` instance given to `guac_client_init` will be shared by the
user that starts the connection, and any users which join the connection via
screen sharing. It lives until the connection is explicitly closed, or until
all users leave the connection.

For this project to build with GNU Automake, we a `configure.ac` file which
describes the name of the project and what it needs configuration-wise.  In
this case, the project is "libguac-client-ball", and it depends on the
"libguac" library used by guacd and all client plugins:

```
# Project information
AC_PREREQ([2.61])
AC_INIT([libguac-client-ball], [0.1.0])
AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects])
AM_SILENT_RULES([yes])

AC_CONFIG_MACRO_DIRS([m4])

# Check for required build tools
AC_PROG_CC
AC_PROG_CC_C99
AC_PROG_LIBTOOL

# Check for libguac
AC_CHECK_LIB([guac], [guac_client_stream_png],,
      AC_MSG_ERROR("libguac is required for communication via "
                   "the Guacamole protocol"))

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
```

We also need a `Makefile.am`, describing which files should be built and how
when building libguac-client-ball:

```
AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4
AM_CFLAGS = -Werror -Wall -pedantic

lib_LTLIBRARIES = libguac-client-ball.la

# All source files of libguac-client-ball
libguac_client_ball_la_SOURCES = src/ball.c

# libtool versioning information
libguac_client_ball_la_LDFLAGS = -version-info 0:0:0
```

The GNU Automake files will remain largely unchanged throughout the rest of the
tutorial.

Once you have created all of the above files, you will have a functioning
client plugin. It doesn't do anything yet, and any connection will be extremely
short-lived (the lack of any data sent by the server will lead to the client
disconnecting under the assumption that the connection has stopped responding),
but it does technically work.

(libguac-client-ball-display-init)=

Initializing the remote display
-------------------------------

Now that we have a basic functioning skeleton, we need to actually do something
with the remote display. A good first step would be simply initializing the
display - setting the remote display size and providing a basic background.

In this case, we'll set the display to a nice default of 1024x768, and fill the
background with gray. Though the size of the display *can* be chosen based on
the size of the user's browser window (which is provided by the user during the
[Guacamole protocol handshake](guacamole-protocol-handshake), or even updated
when the window size changes (provided by the user via ["size"
instructions](client-size-instruction)), we won't be doing that here for
simplicity's sake:

```c
#include <guacamole/client.h>
#include <guacamole/protocol.h>
#include <guacamole/socket.h>
#include <guacamole/user.h>

#include <stdlib.h>

...

int ball_join_handler(guac_user* user, int argc, char** argv) {

    /* Get client associated with user */
    guac_client* client = user->client;

    /* Get user-specific socket */
    guac_socket* socket = user->socket;

    /* Send the display size */
    guac_protocol_send_size(socket, GUAC_DEFAULT_LAYER, 1024, 768);

    /* Prepare a curve which covers the entire layer */
    guac_protocol_send_rect(socket, GUAC_DEFAULT_LAYER,
            0, 0, 1024, 768);

    /* Fill curve with solid color */
    guac_protocol_send_cfill(socket,
            GUAC_COMP_OVER, GUAC_DEFAULT_LAYER,
            0x80, 0x80, 0x80, 0xFF);

    /* Mark end-of-frame */
    guac_protocol_send_sync(socket, client->last_sent_timestamp);

    /* Flush buffer */
    guac_socket_flush(socket);

    /* User successfully initialized */
    return 0;

}

int guac_client_init(guac_client* client) {

    /* This example does not implement any arguments */
    client->args = TUTORIAL_ARGS;

    /* Client-level handlers */
    client->join_handler = ball_join_handler;

    return 0;

}
```

The most important thing to notice here is the new `ball_join_handler()`
function. As it is assigned to `join_handler` of the `guac_client` given to
`guac_client_init`, users which join the connection (including the user that
opened the connection in the first place) will be passed to this function. It
is the duty of the join handler to initialize the provided `guac_user`, taking
into account any arguments received from the user during the connection
handshake (exposed through `argc` and `argv` to the join handler). We aren't
implementing any arguments, so these values are simply ignored, but we do need
to initialize the user with respect to display state. In this case, we:

1. Send a ["size" instruction](size-instruction), initializing the display size
   to 1024x768.

2. Draw a 1024x768 gray rectangle over the display using the
   ["rect"](rect-instruction) and ["cfill"](cfill-instruction) instructions.

3. Send a ["sync" instruction](sync-instruction), informing the remote display
   that a frame has been completed.

4. Flush the socket, ensuring that all data written to the socket thus far is
   immediately sent to the user.

At this point, if you build, install, and connect using the plugin, you will
see a gray screen. The connection will still be extremely short-lived, however,
since the only data ever sent by the plugin is sent when the user first joins.
The lack of any data sent by the server over the remaining life of the
connection will lead to the client disconnecting under the assumption that the
connection has stopped responding. This will be rectified shortly once we add
the bouncing ball.

(libguac-client-ball-layer)=

Adding the ball
---------------

This tutorial is about making a bouncing ball "client", so naturally we need a
ball to bounce. While we could repeatedly draw and erase a ball on the remote
display, a more efficient technique would be to leverage Guacamole's layers.

The remote display has a single root layer, `GUAC_DEFAULT_LAYER`, but there can
be infinitely many other child layers, which can themselves have child layers,
and so on. Each layer can be dynamically repositioned within and relative to
another layer. Because the compositing of these layers is handled by the remote
display, and is likely hardware-accelerated, this is a much better way to
repeatedly reposition something we expect to move a lot.

Since we're finally adding the ball, and there needs to be some structure which
maintains the state of the ball, we must create a header file,
`src/ball.h`, to define this:

```c
#ifndef BALL_H
#define BALL_H

#include <guacamole/layer.h>

typedef struct ball_client_data {

    guac_layer* ball;

} ball_client_data;

#endif
```

To make the build system aware of the existence of the new `src/ball.h` header
file, `Makefile.am` must be updated as well:

```
...

# All source files of libguac-client-ball
noinst_HEADERS = src/ball.h
libguac_client_ball_la_SOURCES = src/ball.c

...
```

This new structure is intended to house the client-level state of the ball,
independent of any users which join or leave the connection. The structure must
be allocated when the client begins (within `guac_client_init`), freed when the
client terminates (via a new client free handler), and must contain the layer
which represents the ball within the remote display. As this layer is part of
the remote display state, it must additionally be initialized when a user
joins, in the same way that the display overall was initialized in earlier
steps:

```c
#include "ball.h"

#include <guacamole/client.h>
#include <guacamole/layer.h>
#include <guacamole/protocol.h>
#include <guacamole/socket.h>
#include <guacamole/user.h>

#include <stdlib.h>

...

int ball_join_handler(guac_user* user, int argc, char** argv) {

    /* Get client associated with user */
    guac_client* client = user->client;

    /* Get ball layer from client data */
    ball_client_data* data = (ball_client_data*) client->data;
    guac_layer* ball = data->ball;

    ...

    /* Set up ball layer */
    guac_protocol_send_size(socket, ball, 128, 128);

    /* Prepare a curve which covers the entire layer */
    guac_protocol_send_rect(socket, ball,
            0, 0, 128, 128);

    /* Fill curve with solid color */
    guac_protocol_send_cfill(socket,
            GUAC_COMP_OVER, ball,
            0x00, 0x80, 0x80, 0xFF);

    /* Mark end-of-frame */
    guac_protocol_send_sync(socket, client->last_sent_timestamp);

    /* Flush buffer */
    guac_socket_flush(socket);

    /* User successfully initialized */
    return 0;

}

int ball_free_handler(guac_client* client) {

    ball_client_data* data = (ball_client_data*) client->data;

    /* Free client-level ball layer */
    guac_client_free_layer(client, data->ball);

    /* Free client-specific data */
    free(data);

    /* Data successfully freed */
    return 0;

}

int guac_client_init(guac_client* client) {

    /* Allocate storage for client-specific data */
    ball_client_data* data = malloc(sizeof(ball_client_data));

    /* Set up client data and handlers */
    client->data = data;

    /* Allocate layer at the client level */
    data->ball = guac_client_alloc_layer(client);

    ...

    /* Client-level handlers */
    client->join_handler = ball_join_handler;
    client->free_handler = ball_free_handler;

    return 0;

}
```

The allocate/free pattern for the client-specific data and layers should be
pretty straightforward - the allocation occurs when the objects (the layer and
the structure housing it) are first needed, and the allocated objects are freed
once they are no longer needed (when the client terminates) to avoid leaking
memory. The initialization of the ball layer using the Guacamole protocol
should be familiar as well - it's identical to the way the screen was
initialized, and involves the same instructions.

Beyond layers, Guacamole has the concept of buffers, which are identical in use
to layers except they are invisible. Buffers are used to store image data for
the sake of caching or drawing operations. We will use them later when we try
to make this tutorial prettier. If you build and install the ball client as-is
now, you will see a large gray rectangle (the root layer) with a small blue
square in the upper left corner (the ball layer).

(libguac-client-ball-bounce)=

Making the ball bounce
----------------------

To make the ball bounce, we need to track the ball's state, including current
position and velocity, as well as a thread which updates the ball's state (and
the remote display) as time progresses. The ball state and thread can be stored
alongside the ball layer in the existing client-level data structure:

```c
...

#include <guacamole/layer.h>

#include <pthread.h>

typedef struct ball_client_data {

    guac_layer* ball;

    int ball_x;
    int ball_y;

    int ball_velocity_x;
    int ball_velocity_y;

    pthread_t render_thread;

} ball_client_data;

...
```

The contents of the thread will update these values at a pre-defined rate,
changing ball position with respect to velocity, and changing velocity with
respect to collisions with the display boundaries:

```c
#include "ball.h"

#include <guacamole/client.h>
#include <guacamole/layer.h>
#include <guacamole/protocol.h>
#include <guacamole/socket.h>
#include <guacamole/user.h>

#include <pthread.h>
#include <stdlib.h>

...

void* ball_render_thread(void* arg) {

    /* Get data */
    guac_client* client = (guac_client*) arg;
    ball_client_data* data = (ball_client_data*) client->data;

    /* Update ball position as long as client is running */
    while (client->state == GUAC_CLIENT_RUNNING) {

        /* Sleep a bit */
        usleep(30000);

        /* Update position */
        data->ball_x += data->ball_velocity_x * 30 / 1000;
        data->ball_y += data->ball_velocity_y * 30 / 1000;

        /* Bounce if necessary */
        if (data->ball_x < 0) {
            data->ball_x = -data->ball_x;
            data->ball_velocity_x = -data->ball_velocity_x;
        }
        else if (data->ball_x >= 1024 - 128) {
            data->ball_x = (2 * (1024 - 128)) - data->ball_x;
            data->ball_velocity_x = -data->ball_velocity_x;
        }

        if (data->ball_y < 0) {
            data->ball_y = -data->ball_y;
            data->ball_velocity_y = -data->ball_velocity_y;
        }
        else if (data->ball_y >= 768 - 128) {
            data->ball_y = (2 * (768 - 128)) - data->ball_y;
            data->ball_velocity_y = -data->ball_velocity_y;
        }

        guac_protocol_send_move(client->socket, data->ball,
                GUAC_DEFAULT_LAYER, data->ball_x, data->ball_y, 0);

        /* End frame and flush socket */
        guac_client_end_frame(client);
        guac_socket_flush(client->socket);

    }

    return NULL;

}

...
```

Just as with the join handler, this thread sends a "sync" instruction to denote
the end of each frame, though here this is accomplished with
`guac_client_end_frame()`. This function sends a "sync" containing the current
timestamp, and updates the properties of the `guac_client` with the last-sent
timestamp (the value that our join handler uses to send *its* sync). Note that
we don't redraw the whole display with each frame - we simply update the
position of the ball layer using a ["move" instruction](move-instruction), and
rely on the remote display to handle compositing on its own.

We now need to update `guac_client_init` to actually create this thread,
initialize the ball state within the structure, and store the thread for future
cleanup when the client terminates:

```c
...

int ball_free_handler(guac_client* client) {

    ball_client_data* data = (ball_client_data*) client->data;

    /* Wait for render thread to terminate */
    pthread_join(data->render_thread, NULL);

    ...

}

int guac_client_init(guac_client* client) {

    ...

    /* Start ball at upper left */
    data->ball_x = 0;
    data->ball_y = 0;

    /* Move at a reasonable pace to the lower right */
    data->ball_velocity_x = 200; /* pixels per second */
    data->ball_velocity_y = 200; /* pixels per second */

    /* Start render thread */
    pthread_create(&data->render_thread, NULL, ball_render_thread, client);

    ...

}
```

The thread contains a render loop which continually checks the state property
of the `guac_client`. This property is set to `GUAC_CLIENT_RUNNING` when the
connection begins, and remains that way for the duration of the connection.
When guacd needs to terminate the connection (such as when the last user
leaves), the value will change to `GUAC_CLIENT_STOPPING`. The free handler
we've written can thus rely on `pthread_join()` to block until the data
previously used by the plugin is no longer being used and can safely be freed.

Once built and installed, our ball client now has a bouncing ball, albeit a
very square and plain one. Now that the display is continually updating, and
data is being continually received from the server, connected clients will no
longer automatically disconnect.

(libguac-client-ball-pretty)=

A prettier ball
---------------

Now that we have our ball bouncing, we might as well try to make it actually
look like a ball, and try applying some of the fancier graphics features that
Guacamole offers. Guacamole provides instructions common to most 2D drawing
APIs, including HTML5's canvas and Cairo. This means you can draw arcs, curves,
apply fill and stroke, and even use the contents of another layer or buffer as
the pattern for a fill or stroke.  In complex cases involving many draw
operations, it will actually be more efficient to render to a server-side Cairo
surface and send only image data to the client, but it's perfect for relatively
simple cases like our ball.

We will try creating a simple gray checkerboard pattern in a buffer, using that
for the background instead of the previous gray rectangle, and will modify the
ball by replacing the rectangle with an arc, in this case a full circle,
complete with stroke (border) and translucent-blue fill:

```c
int ball_join_handler(guac_user* user, int argc, char** argv) {

    ...

    /* Create background tile */
    guac_layer* texture = guac_client_alloc_buffer(client);

    guac_protocol_send_rect(socket, texture, 0, 0, 64, 64);
    guac_protocol_send_cfill(socket, GUAC_COMP_OVER, texture,
            0x88, 0x88, 0x88, 0xFF);

    guac_protocol_send_rect(socket, texture, 0, 0, 32, 32);
    guac_protocol_send_cfill(socket, GUAC_COMP_OVER, texture,
            0xDD, 0xDD, 0xDD, 0xFF);

    guac_protocol_send_rect(socket, texture, 32, 32, 32, 32);
    guac_protocol_send_cfill(socket, GUAC_COMP_OVER, texture,
            0xDD, 0xDD, 0xDD, 0xFF);


    /* Prepare a curve which covers the entire layer */
    guac_protocol_send_rect(socket, GUAC_DEFAULT_LAYER,
            0, 0, 1024, 768);

     /* Fill curve with texture */
    guac_protocol_send_lfill(socket,
            GUAC_COMP_OVER, GUAC_DEFAULT_LAYER,
            texture);

    /* Set up ball layer */
    guac_protocol_send_size(socket, ball, 128, 128);

    /* Prepare a circular curve */
    guac_protocol_send_arc(socket, data->ball,
            64, 64, 62, 0, 6.28, 0);

    guac_protocol_send_close(socket, data->ball);

    /* Draw a 4-pixel black border */
    guac_protocol_send_cstroke(socket,
            GUAC_COMP_OVER, data->ball,
            GUAC_LINE_CAP_ROUND, GUAC_LINE_JOIN_ROUND, 4,
            0x00, 0x00, 0x00, 0xFF);

    /* Fill the circle with color */
    guac_protocol_send_cfill(socket,
            GUAC_COMP_OVER, data->ball,
            0x00, 0x80, 0x80, 0x80);

    /* Free texture (no longer needed) */
    guac_client_free_buffer(client, texture);

    /* Mark end-of-frame */
    guac_protocol_send_sync(socket, client->last_sent_timestamp);

    ...

}
```

Again, because we put the ball in its own layer, we don't have to worry about
compositing it ourselves. The remote display will handle this, and will likely
do so with hardware acceleration, even though the ball is now translucent.
Build and install the ball client after this step, and you will have a rather
nice-looking bouncing ball.

(libguac-client-ball-time)=

Handling the passage of time
----------------------------

There are never any guarantees when it comes to timing, threads, and network
performance. We cannot necessarily rely on the remote display to handle updates
in a timely manner (it may be slow), nor can we rely on the network or server
to give priority to communication from guacd.

The render thread needs to be modified to take this into account, by tracking
the actual time spent within each frame, and estimating the amount of time the
client spends rendering each frame:

```c
#include "ball.h"

#include <guacamole/client.h>
#include <guacamole/layer.h>
#include <guacamole/protocol.h>
#include <guacamole/socket.h>
#include <guacamole/timestamp.h>
#include <guacamole/user.h>

#include <pthread.h>
#include <stdlib.h>

...

void* ball_render_thread(void* arg) {

    ...

    /* Init time of last frame to current time */
    guac_timestamp last_frame = guac_timestamp_current();

    /* Update ball position as long as client is running */
    while (client->state == CLIENT_RUNNING) {

        /* Default to 30ms frames */
        int frame_duration = 30;

        /* Lengthen frame duration if client is lagging */
        int processing_lag = guac_client_get_processing_lag(client);
        if (processing_lag > frame_duration)
            frame_duration = processing_lag;

        /* Sleep for duration of frame, then get timestamp */
        usleep(frame_duration);
        guac_timestamp current = guac_timestamp_current();

        /* Calculate change in time */
        int delta_t = current - last_frame;

        /* Update position */
        data->ball_x += data->ball_velocity_x * delta_t / 1000;
        data->ball_y += data->ball_velocity_y * delta_t / 1000;

        ...

        /* Update timestamp */
        last_frame = current;

    }

    ...

}
```

The calculations are pretty simple. Rather than hard-code the duration of each
frame, we us a default of 30 milliseconds, lengthening the frame if Guacamole's
built-in lag estimation determines that the client is having trouble. The
physics portion of the update no longer assumes that the frame will be exactly
30 milliseconds, instead relying on the actual time elapsed since the previous
frame.

At this point, we now have a robust Guacamole client plugin. It handles
joining/leaving users correctly, continually updates the remote display state
while taking into account variable network/server/client conditions, and cleans
up after itself when the connection finally terminates.

