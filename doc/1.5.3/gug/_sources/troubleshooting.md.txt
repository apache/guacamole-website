Troubleshooting
===============

(not-working)=

It isn't working
----------------

If Guacamole isn't working, chances are something isn't configured properly, or
something is wrong with the network. Thankfully, Guacamole and all its
components log errors thoroughly, so the problem can usually be traced down
fairly easily if you know where to look. Troubleshooting Guacamole usually
boils down to checking either syslog or your servlet container's logs (likely
Tomcat).

Failing all that, you can always post a question on [one of the project mailing
lists](http://guacamole.apache.org/support/#mailing-lists), or if you truly
feel you've discovered a bug, you can [create a new ticket in
JIRA](https://issues.apache.org/jira/browse/GUACAMOLE/). Beware that if
something isn't working, and there are errors in the logs describing the
problem, [it is usually not a
bug](http://guacamole.apache.org/faq/#probably-not-a-bug), and the best place
to handle such things is through consulting this guide or the mailing lists.

### No graphics appear

If you *never* see any graphics appear, or you see "Connecting, waiting for
first update..." for a while and then are disconnected, the most likely cause
is a proxy.

Guacamole relies on streaming data to you over a persistent connection.  If
software between Guacamole and your browser is buffering all incoming data,
such as a proxy, this data never makes it to your browser, and you will just
see it wait indefinitely. Eventually, thinking the client has disconnected,
Guacamole closes the connection, at which point the proxy finally flushes its
buffer and you see graphics! ... just in time to see it disconnect.

The solution here is to either modify your proxy settings to flush packets
immediately as they are received, or to use HTTPS. Proxies are required to pass
HTTPS through untouched, and this usually solves the problem.

Even if you aren't aware of any proxy, there may be one in place.  Corporate
firewalls very often incorporate proxies. Antivirus software may buffer
incoming data until the connection is closed and the data is scanned for
viruses. Virtualization software may detect HTTP data and buffer the connection
just like a proxy. If all else fails, try HTTPS - it's the only secure way to
do this anyway.

### Connections involving Unicode don't work

If you are using Tomcat, beware that you *must* set the `URIEncoding="UTF-8"`
attribute on all connectors in your `server.xml`. If you are using a different
servlet container, you need to find out whether it requires special options to
support UTF-8 in URIs, and change the required settings to enable such support.

Without UTF-8 support enabled for URIs, Unicode characters in connection names
will not be received properly when connecting, and Guacamole will think the
connection you requested does not exist. Similarly, if you are using the
built-in administration interface, parameters involving Unicode characters will
not save properly without these options enabled.

syslog
------

guacd and libguac-based programs (such as all client plugins) log informational
messages and errors to syslog. Specifically, guacd uses syslog, and it exposes
this logging facility to everything it loads (client plugins), thus if the VNC
or RDP support plugins encounter errors, they log those errors over the logging
facilities exposed by guacd, in this case syslog.

Once you guacd is started, you'll see entries like the following in syslog:

```
guacd[19663]: Guacamole proxy daemon (guacd) version 0.7.0
guacd[19663]: Unable to bind socket to host ::1, port 4823: Address family
              not supported by protocol
guacd[19663]: Successfully bound socket to host 127.0.0.1, port 4823
guacd[19663]: Exiting and passing control to PID 19665
guacd[19665]: Exiting and passing control to PID 19666
guacd[19666]: Listening on host 127.0.0.1, port 4823
```

Each entry relevant to Guacamole has the prefix "guacd", denoting the program
that produced the entry, followed by the process ID, followed by the message.
The entries above show guacamole starting successfully and listening on a
non-default port 4823.

### guacd errors

#### Unable to bind socket to any addresses.

This means that guacd failed to start up at all because the port it wants to
listen on is already taken at all addresses attempted. The details of what
guacd tried will be listed in the log entries above this. To solve the problem,
find what port guacd was trying to listen on (the default is 4822) and check if
any other service is listening on that port.

If another service is listening on the default port, you can always specify a
non-standard port for guacd by using the `-l PORT` option (that's a lowercase
"L", not a number "1"), where <PORT> is the number of the port to listen on.
Beware that you will likely have to modify `guacamole.properties` so that
Guacamole knows how to connect to guacd.

#### Unable to start input thread

guacd creates two threads for each connection: one that receives input from the
connected client, and the other that produces output for the client. If either
of these fails to start, the above error will be logged along with the cause.

If it is the output thread that fails to start, the message will instead read:
"Unable to start output thread".

#### Client finished abnormally

If the client plugin ever returns an error code, this will cause the connection
to immediately terminate, with the cause of the error specific to the plugin in
use. The cause should be detailed in the log messages above the error. If those
log messages don't make sense, you may have found a bug.

#### Could not fork() parent

When guacd starts up, it immediately attempts to "fork" into the background
(unless instructed otherwise). The word "fork()" above is a reference to the C
function call that does this. There are several calls to this function, each of
which might fail if system resources are lacking or something went wrong at a
low level. If you see this message, it is probably not a bug in Guacamole, but
rather a problem with the load level of your system.

This message may also appear as "Could not fork() group leader".

#### Unable to change working directory to /

One of the duties of guacd as it starts up is to change its working directory
to the root directory. This is to prevent locking the current directory in case
it needs to be unmounted, etc. If guacd cannot do this, this error will be
logged, along with the cause.

#### Unable to redirect standard file descriptors to /dev/null

As guacd starts, it also has to redirect STDOUT, STDERR, and STDIN to
`/dev/null` such that attempts to use these output mechanisms do not pollute
the active console. Though guacd and client plugins will use the exposed
logging facilities (and thus syslog) rather than STDOUT or STDERR, libraries
used by client plugins are often written only from the mindset of a typical
client, and use standard output mechanisms for debug logging. Not redirecting
these would result in undesired output to the console.

If guacd cannot redirect these file descriptors for any reason, this error will
be logged, along with the cause.

####  Error parsing given address or port: HOSTNAME

If you specified a host or port to listen on via commandline options, and that
host or port is actually invalid, you will see this error. Fix the
corresponding option and try again.

#### Error opening socket

When guacd starts up, it needs to open a socket and then listen on that socket.
If it can't even open the socket, this error will be logged, and guacd will
exit. The cause is most likely related to permissions, and is logged along with
the error.

#### Unable to resolve host

If the hostname you specified on the commandline cannot be found, you will see
this error. Note that this error is from guacd, and does not relate to whatever
remote desktop servers you may be trying to use; it relates only to the host
guacd is trying to listen on. Check the hostname or IP address specified on the
commandline. If that checks out, there may be a problem with your DNS or your
network.

#### Could not become a daemon

In order to become a "daemon" (that is, in order to run in the background as a
system process), guacd must create and exit from several processes, redirect
file descriptors, etc. If any of these steps fails, guacd will not become a
daemon, and it will log this message and exit.  The reason guacd could not
become a daemon will be in the previous error message in the logs.

#### Could not write PID file

guacd offers a commandline option that lets you specify a file that it should
write its process ID into, which is useful for init scripts. If you see this
error, it likely means the user guacd is running as does not have permission to
write this file. The true cause of the error will be logged in the same entry.
Check which user guacd is running as, and then check that it has write
permission to the file in question.

#### Could not listen on socket

When guacd starts up, it needs to listen on the socket it just opened in order
to accept connections. If it cannot listen on the socket, clients will be
unable to connect. If, for any reason, guacd is unable to listen on the socket,
guacd will exit and log this message along with the cause, which is most likely
a low-level system resource problem.

#### Could not accept client connection

When a client connects to guacd, it must accept the connection in order for
communication to ensue. If it cannot even accept the connection, no
communication between server and client will happen, and this error will be
logged. The cause of the error will be logged in the same entry.  Possible
causes include permissions problems, or lack of server resources.

#### Error forking child process

When a client connects to guacd, it must create a new process to handle the
connection while the old guacd process continues to listen for new connections.
If, for any reason, guacd cannot create this process, the connection from that
client will be denied, and the cause of the error will be logged. Possible
causes include permissions problems, or lack of server resources.

#### Error closing daemon reference to child descriptor

When guacd receives a connection, and it creates a new process to handle that
connection, it gains a copy of the file descriptor that the client will use for
communication. As this connection can never be closed unless all references to
the descriptor are closed, the server must close its copy such that the client
is the only remaining holder of the file descriptor. If the server cannot close
the descriptor, it will log this error message along with the cause.

#### Error sending "sync" instruction

During the course of a Guacamole session, guacd must occasionally "ping" the
client to make sure it is still alive. This ping takes the form of a "sync"
instruction, which the client is obligated to respond to as soon as it is
received. If guacd cannot send this instruction, this error will be logged,
along with the cause. Chances are the connection has simply been closed, and
this error can be ignored.

#### Error flushing output

After the client plugin is finished (for the time being) with handling server
messages, the socket is automatically flushed. If the server cannot flush this
socket for some reason, such as the connection already being closed, you will
see this error. Normally, this error does not indicate a problem, but rather
that the client has simply closed the connection.

#### Error handling server messages

While the client plugin is running, guacd will occasionally ask the plugin to
check and handle any messages that it may have received from the server it
connected to. If the client plugin fails for some reason while doing this, this
error will be logged, and the cause of the error will likely be logged in
previous log entries by the client plugin.

#### Error reading instruction

During the course of a Guacamole session, instructions are sent from client to
server which are to be handled by the client plugin. If an instruction cannot
be read, this error will be logged. Usually this means simply that the
connection was closed, but it could also indicate that the version of the
client in use is so old that it doesn't support the current Guacamole protocol
at all. If the cause looks like the connection was closed (end of stream
reached, etc.), this log entry can be ignored. Otherwise, if the first two
numbers of the version numbers of all Guacamole components match, you have
probably found a bug.

#### Client instruction handler error

This error indicates that a client plugin failed inside the handler for a
specific instruction. When the server receives instructions from the client, it
then invokes specific instruction handlers within the client plugin. In
general, this error is not useful to a user or system administrator. If the
cause looks benign, such as reaching the end of a stream (the connection
closed), it can be ignored as normal. Otherwise, this error can indicate a bug
either in the client plugin or in a library used by the client plugin.

It can also indicate a problem in the remote desktop server which is causing
the client plugin to fail while communicating with it.

#### Error reading OPCODE

During the handshake of the Guacamole protocol, the server expects a very
specific sequence of instructions to be received. If the wrong instructions are
received, or the connection is abruptly closed during the handshake, the above
error will occur.

In the case that the cause is the connection closing, this is normal, and
probably just means that the client disconnected before the initial handshake
completed.

If the connection was not closed abruptly, but instead the wrong instruction
was received, this could mean either that the connecting client is from an
incompatible version of Guacamole (and thus does not know the proper handshake
procedure) or you have found a bug. Check whether all installed components came
from the same upstream release bundle.

#### Error sending "args"

During the handshake of the Guacamole protocol, the server must expose all
parameters used by the client plugin via the args instruction. If this cannot
be sent, you will see this error in the logs. The cause will be included in the
error message, and usually just indicates that the connection was closed during
the handshake, and thus the handshake cannot continue.

#### Error loading client plugin

When the client connects, it sends an instruction to guacd informing it what
protocol it wishes to use. If the corresponding client plugin cannot be found
or used for any reason, this message will appear in the logs. Normally this
indicates that the corresponding client plugin is not actually installed. The
cause listed after the error message will indicate whether this is the case.

#### Error instantiating client

After the client plugin is loaded, an initialization function provided by the
client plugin is invoked. If this function fails, then the client itself cannot
be created, and this error will be logged. Usually this indicates that one or
more of the parameters given to the client plugin are incorrect or malformed.
Check the configuration of the connection in use at the time.

### libguac-client-vnc errors

#### Error waiting for VNC message

The VNC client plugin must wait for messages sent by the VNC server, and handle
them when they arrive. If there was an error while waiting for a message from
the VNC server, this error message will be displayed.  Usually this means that
the VNC server closed the connection, or there is a problem with the VNC server
itself, but the true cause of the error will be logged.

#### Error handling VNC server message

When messages are received from the VNC server, libvncclient must handle them
and then invoke the functions of libguac-client-vnc as necessary.  If
libvncclient fails during the handling of a received message, this error will
be logged, along with (hopefully) the cause. This may indicate a problem with
the VNC server, or a lack of support within libvncclient.

#### Wrong argument count received

The connecting client is required to send exactly the same number of arguments
as requested by the client plugin. If you see this message, it means there is a
bug in the client connecting to guacd, most likely the web application.

### libguac-client-rdp errors

#### Invalid PARAMETER

If one of the parameters given, such as "width", "height", or "color-depth", is
invalid (not an integer, for example), you will receive this error. Check the
parameters of the connection in use and try again.

#### Support for the CLIPRDR channel (clipboard redirection) could not be loaded

FreeRDP provides a plugin which provides clipboard support for RDP. This plugin
is typically built into FreeRDP, but some distributions may bundle this
separately. libguac-client-rdp loads this plugin in order to support clipboard,
as well. If this plugin could not be loaded, then clipboard support will not be
available, and the reason will be logged.

#### Cannot create static channel "NAME": failed to load "guac-common-svc" plugin for FreeRDP

RDP provides support for much of its feature set through static virtual
channels. Sound support, for example is provided through the "RDPSND" channel.
Device redirection for printers and drives is provided through "RDPDR". To
support these and other static virtual channels, libguac-client-rdp builds a
plugin for FreeRDP called "guac-common-svc" which allows Guacamole to hook into
the parts of FreeRDP that support virtual channels.

If libguac-client-rdp cannot load this plugin, support for any features which
leverage static virtual channels will not work, and the reason will be logged.
A likely explanation is that libguac-client-rdp was built from source, and the
directory specified for FreeRDP's installation location was incorrect. For
FreeRDP to be able to find plugins, those plugins must be placed in the
`freerdp2/` subdirectory of whichever directory contains the `libfreerdp2.so`
library.

#### Server requested unsupported clipboard data type

When clipboard support is loaded, libguac-client-rdp informs the RDP server of
all supported clipboard data types. The RDP server is required to send only
those types supported by the client. If the server decides to send an
unsupported type anyway, libguac-client-rdp ignores the data sent, and logs
this message.

#### Clipboard data missing null terminator

When text is sent via a clipboard message, it is required to have a terminating
null byte. If this is not the case, the clipboard data is invalid, and
libguac-client-rdp ignores it, logging this error message.

Servlet container logs
----------------------

Your servlet container will have logs which the web application side of
Guacamole will log errors to. In the case of Tomcat, this is usually
`catalina.out` or `HOSTNAME.log` (for example, `localhost.log`).

(user-mapping-xml-errors)=

### `user-mapping.xml` errors

Errors in the relating to the `user-mapping.xml` file usually indicate that
either the XML is malformed, or the file itself cannot be found.

#### Attribute "name" required for connection tag

If you specify a connection with a `<connection>` tag, it must have a
corresponding name set via the `name` attribute. If it does not, then the XML
is malformed, and this error will be logged. No users will be able to login.

#### Attribute "name" required for param tag

Each parameter specified with a `<param>` tag must have a corresponding name
set via the `name` attribute. If it does not, then the XML is malformed, and
this error will be logged. No users will be able to login.

#### Unexpected character data

Character data (text not within angle brackets) can only exist within the
`<param>` tag. If it exists elsewhere, then the XML is malformed, and this
error will be logged. No users will be able to login.

#### Invalid encoding type

There are only two legal values for the `encoding` attribute of the
`<authorize>` tag: `plain` (indicating plain text) and `md5` (indicating a
value hashed with the MD5 digest). If any other value is used, then the XML is
malformed, and this error will be logged. No users will be able to login.

#### User mapping could not be read

If for any reason the user mapping file cannot be read (the servlet container
lacks read permission for the file, the file does not exist, etc.), this error
will be logged. Check `guacamole.properties` to see where the user mapping file
is specified to exist, and then check that is both exists and is readable by
your servlet container.

(guacamole-properties-errors)=

### `guacamole.properties` errors

If a property is malformed or a required property is missing, an error
describing the problem will be logged.

#### Property PROPERTY is required

If Guacamole or an extension of Guacamole requires a specific property in
`guacamole.properties`, but this property is not defined, this error will be
logged. Check which properties are required by the authentication provider (or
other extensions) in use, and then compare that against the properties within
`guacamole.properties`.

(guacamole-auth-errors)=

### Authentication errors

If someone attempts to login with invalid credentials, or someone attempts to
access a resource or connection that does not exist or they do not have access
to, errors regarding the invalid attempt will be logged.

#### Cannot connect - user not logged in

A user attempted to connect using the HTTP tunnel, and while the tunnel does
exist and is attached to their session, they are not actually logged in.
Normally, this isn't strictly possible, as a user has to have logged in for a
tunnel to be attached to their session, but as it isn't an impossibility, this
error does exist. If you see this error, it could mean that the user logged out
at the same time that they made a connection attempt.

#### Requested configuration is not authorized

A user attempted to connect to a configuration with a given ID, and while that
configuration does exist, they are not authorized to use it.  This could mean
that the user is trying to access things they have no privileges for, or that
they are trying to access configurations they legitimately should, but are
actually logged out.

#### User has no session

A user attempted to access a page that needs data from their session, but their
session does not actually exist. This usually means the user has not logged in,
as sessions are created through the login process.

(guacamole-tunnel-errors)=

### Tunnel errors

The tunnel frequently returns errors if guacd is killed, the connection is
closed, or the client abruptly closes the connection.

#### No such tunnel

An attempt was made to use a tunnel which does not actually exist. This is
usually just the JavaScript client sending a leftover message or two while it
hasn't realized that the server has disconnected. If this error happens
consistently and is associated with Guacamole generally not working, it could
be a bug.

#### No tunnel created

A connection attempt for a specific configuration was made, but the connection
failed, and no tunnel was created. This is usually because the user was not
authorized to use that connection, and thus no tunnel was created for access to
that connection.

#### No query string provided

When the JavaScript client is communicating with the HTTP tunnel, it *must*
provide data in the query string describing whether it wants to connect, read,
or write. If this data is missing as the error indicates, there is a bug in the
HTTP tunnel.

#### Tunnel reached end of stream

An attempt to read from the tunnel was made, but the tunnel in question has
already reached the end of stream (the connection is closed). This is mostly an
informative error, and can be ignored.

#### Tunnel is closed

An attempt to read from the tunnel was made, but the tunnel in question is
already closed. This can happen if the client or guacd have closed the
connection, but the client has not yet settled down and is still making read
attempts. As there can be lags between when connections close and when the
client realizes it, this can be safely ignored.

#### End of stream during initial handshake

If guacd closes the connection suddenly without allowing the client to complete
the initial handshake required by the Guacamole protocol, this error will
appear in the logs. If you see this error, you should check syslog for any
errors logged by guacd to determine why it closed the connection so early.

#### Element terminator of instruction was not ';' nor ','

The Guacamole protocol imposes a strict format which requires individual parts
of instructions (called "elements") to end with either a ";" or "," character.
If they do not, then something has gone wrong during transmission. This usually
indicates a bug in the client plugin in use, guacd, or libguac.

#### Non-numeric character in element length

The Guacamole protocol imposes a strict format which requires each element of
an instruction to have a length prefix, which must be composed entirely of
numeric characters (digits 0 through 9). If a non-numeric character is read,
then something has gone wrong during transmission. This usually indicates a bug
in the client plugin in use, guacd, or libguac.

