guacamole-common
================

The Java API provided by the Guacamole project is called guacamole-common. It
provides a basic means of tunneling data between the JavaScript client provided
by guacamole-common-js and the native proxy daemon, guacd, and for dealing with
the Guacamole protocol. The purpose of this library is to facilitate the
creation of custom tunnels between the JavaScript client and guacd, allowing
your Guacamole-driven web application to enforce its own security model, if
any, and dictate exactly what connections are established.

(java-http-tunnel)=

HTTP tunnel
-----------

The Guacamole Java API implements the HTTP tunnel using a servlet called
`GuacamoleHTTPTunnelServlet`. This servlet handles all requests coming to it
over HTTP from the JavaScript client, and translates them into connect, read,
or write requests, which each get dispatched to the `doConnect()`, `doRead()`,
and `doWrite()` functions accordingly.

Normally, you wouldn't touch the `doRead()` and `doWrite()` functions, as these
have already been written to properly handle the requests of the JavaScript
tunnel, and if you feel the need to touch these functions, you are probably
better off writing your own tunnel implementation, although such a thing is
difficult to do in a performant way.

When developing an application based on the Guacamole API, you should use
`GuacamoleHTTPTunnelServlet` by extending it, implementing your own version of
`doConnect()`, which is the only abstract function it defines. The tutorial
later in this book demonstrating how to write a Guacamole-based web application
shows the basics of doing this, but generally, `doConnect()` is an excellent
place for authentication or other validation, as it is the responsibility of
`doConnect()` to create (or not create) the actual tunnel. If `doConnect()`
does not create the tunnel, communication between the JavaScript client and
guacd cannot take place, which is an ideal power to have as an authenticator.

The `doConnect()` function is expected to return a new `GuacamoleTunnel`, but
it is completely up to the implementation to decide how that tunnel is to be
created. The already-implemented parts of `GuacamoleHTTPTunnelServlet` then
return the unique identifier of this tunnel to the JavaScript client, allowing
its own tunnel implementation to continue to communicate with the tunnel
existing on the Java side.

Instances of `GuacamoleTunnel` are associated with a `GuacamoleSocket`, which
is the abstract interface surrounding the low-level connection to guacd.
Overall, there is a socket (`GuacamoleSocket`) which provides a TCP connection
to guacd. This socket is exposed to `GuacamoleTunnel`, which provides abstract
protocol access around what is actually (but secretly, through the abstraction
of the API) a TCP socket.

The Guacamole web application extends this tunnel servlet in order to implement
authentication at the lowest possible level, effectively prohibiting
communication between the client and any remote desktops unless they have
properly authenticated. Your own implementation can be considerably simpler,
especially if you don't need authentication:

```java
public class MyGuacamoleTunnelServlet
    extends GuacamoleHTTPTunnelServlet {

    @Override
    protected GuacamoleTunnel doConnect(HttpServletRequest request)
        throws GuacamoleException {

        // Connect to guacd here (this is a STUB)
        GuacamoleSocket socket;

        // Return a new tunnel which uses the connected socket
        return new SimpleGuacamoleTunnel(socket);

    }

}
```

(java-protocol-usage)=

Using the Guacamole protocol
----------------------------

guacamole-common provides basic low-level support for the Guacamole protocol.
This low-level support is leveraged by the HTTP tunnel implementation to
satisfy the requirements of the JavaScript client implementation, as the
JavaScript client expects the handshake procedure to have already taken place.
This support exists through the `GuacamoleReader` and `GuacamoleWriter`
classes, which are similar to Java's `Reader` and `Writer` classes, except that
they deal with the Guacamole protocol specifically, and thus have slightly
different contracts.

(java-reading-protocol)=

### `GuacamoleReader`

`GuacamoleReader` provides a very basic `read()` function which is required to
return one or more complete instructions in a `char` array. It also provides
the typical `available()` function, which informs you whether `read()` is
likely to block the next time it is called, and an even more abstract version
of `read()` called `readInstruction()` which returns one instruction at a time,
wrapped within a `GuacamoleInstruction` instance.

Normally, you would not need to use this class yourself. It is used by
`ConfiguredGuacamoleSocket` to complete the Guacamole protocol handshake
procedure, and it is used by `GuacamoleHTTPTunnelServlet` within `doRead()` to
implement the reading half of the tunnel.

The only concrete implementation of `GuacamoleReader` is
`ReaderGuacamoleReader`, which wraps a Java `Reader`, using that as the source
for data to parse into Guacamole instructions. Again, you would not normally
directly use this class, nor instantiate it yourself.  A working, concrete
instance of `GuacamoleReader` can be retrieved from any `GuacamoleSocket` or
`GuacamoleTunnel`.

(java-writing-protocol)=

### `GuacamoleWriter`

`GuacamoleWriter` provides a very basic `write()` function and a more abstract
version called `writeInstruction()` which writes instances of
`GuacamoleInstruction`. These functions are analogous to the `read()` and
`readInstruction()` functions provided by `GuacamoleReader`, and have similar
restrictions: the contract imposed by `write()` requires that written
instructions be complete.

The only concrete implementation of `GuacamoleWriter` is
`WriterGuacamoleWriter`, which wraps a Java `Writer`, using that as the
destination for Guacamole instruction data, but you would not normally directly
use this class, nor instantiate it yourself. It is used by
`ConfiguredGuacamoleSocket` to complete the Guacamole protocol handshake
procedure, and it is used by `GuacamoleHTTPTunnelServlet` within `doWrite()` to
implement the writing half of the tunnel.

If necessary, a `GuacamoleWriter` can be retrieved from any `GuacamoleSocket`
or `GuacamoleTunnel`, but in most cases, the classes provided by the Guacamole
Java API which already use `GuacamoleWriter` will be sufficient.

