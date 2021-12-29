Configuring Guacamole
=====================

After installing Guacamole, you need to configure users and connections before
Guacamole will work. This chapter covers general configuration of Guacamole and
the use of its default authentication method.

Guacamole's default authentication method reads all users and connections from
a single file called `user-mapping.xml`. This authentication method is intended
to be:

1. Sufficient for small deployments of Guacamole.

2. A relatively-easy means of verifying that Guacamole has been properly set
   up.

Other, more complex authentication methods which use backend databases, LDAP,
etc. are discussed in a separate, dedicated chapters.

Regardless of the authentication method you use, Guacamole's configuration
always consists of two main pieces: a directory referred to as
`GUACAMOLE_HOME`, which is the primary search location for configuration files,
and `guacamole.properties`, the main configuration file used by Guacamole and
its extensions.

(guacamole-home)=

`GUACAMOLE_HOME` (`/etc/guacamole`)
---------------------------------------

`GUACAMOLE_HOME` is the name given to Guacamole's configuration directory,
which is located at `/etc/guacamole` by default. All configuration files,
extensions, etc. reside within this directory. The structure of
`GUACAMOLE_HOME` is rigorously defined, and consists of the following optional
files:

`guacamole.properties`
: The main Guacamole configuration file. Properties within this file dictate
  how Guacamole will connect to guacd, and may configure the behavior of
  installed authentication extensions.

`logback.xml`
: Guacamole uses a logging system called Logback for all messages. By
  default, Guacamole will log to the console only, but you can change this
  by providing your own Logback configuration file.

`extensions/`
: The install location for all Guacamole extensions. Guacamole will
  automatically load all `.jar` files within this directory on startup.

`lib/`
: The search directory for libraries required by any Guacamole extensions.
  Guacamole will make the `.jar` files within this directory available to
  all extensions. If your extensions require additional libraries, such as
  database drivers, this is the proper place to put them.

(overriding-guacamole-home)=

### Overriding `GUACAMOLE_HOME`

If you cannot or do not wish to use `/etc/guacamole` for `GUACAMOLE_HOME`, the
location can be overridden through any of the following methods:

1. Creating a directory named `.guacamole`, within the home directory of *the
   user running the servlet container*. This directory will automatically be
   used for `GUACAMOLE_HOME` if it exists.

2. Specifying the full path to an alternative directory with the environment
   variable `GUACAMOLE_HOME`. *Be sure to consult the documentation for your
   servlet container to determine how to properly set environment variables.*

3. Specifying the full path to an alternative directory with the system
   property guacamole.home.

(initial-setup)=

`guacamole.properties`
------------------------

The Guacamole web application uses one main configuration file called
`guacamole.properties`. This file is the common location for all configuration
properties read by Guacamole or any extension of Guacamole, including
authentication providers.

In previous releases, this file had to be in the classpath of your servlet
container. Now, the location of `guacamole.properties` can be explicitly
defined with environment variables or system properties, and the classpath is
only used as a last resort. When searching for `guacamole.properties`,
Guacamole will check, in order:

1. Within `GUACAMOLE_HOME`, as defined above.

2. The classpath of the servlet container.

The `guacamole.properties` file is optional and is used to configure Guacamole
in situations where the defaults are insufficient, or to provide additional
configuration information for extensions. There are several standard properties
that are always available for use:

`api-session-timeout`
: The amount of time, in minutes, to allow Guacamole sessions
  (authentication tokens) to remain valid despite inactivity. If omitted,
  Guacamole sessions will expire after 60 minutes of inactivity.

`api-max-request-size`
: The maximum number of bytes to accept within the entity body of any
  particular HTTP request, where 0 indicates that no limit should be
  applied. If omitted, requests will be limited to 2097152 bytes (2 MB) by
  default. This limit does not apply to file uploads.

  If using a reverse proxy for SSL termination, *keep in mind that reverse
  proxies may enforce their own limits independently of this*. For example,
  [Nginx will enforce a 1 MB request size limit by
  default](nginx-file-upload-size).

`allowed-languages`
: A comma-separated whitelist of language keys to allow as display language
  choices within the Guacamole interface. For example, to restrict Guacamole
  to only English and German, you would specify:

  ```
  allowed-languages: en, de
  ```

  As English is the fallback language, used whenever a translation key is
  missing from the chosen language, English should only be omitted from this
  list if you are absolutely positive that no strings are missing.

  The corresponding JSON of any built-in languages not listed here will
  still be available over HTTP, but the Guacamole interface will not use
  them, nor will they be used automatically based on local browser language.
  If omitted, all defined languages will be available.

`enable-environment-properties`
: If set to "true", Guacamole will first evaluate its environment to obtain
  the value for any given configuration property, before using a value
  specified in `guacamole.properties` or falling back to a default value. By
  enabling this option, you can easily override any other configuration
  property using an environment variable.

  ```
  enable-environment-properties: true
  ```

  When searching for a configuration property in the environment, the name
  of the property is first transformed by converting all lower case
  characters to their upper case equivalents, and by replacing all hyphen
  characters (`-`) with underscore characters (`_`). For example, the
  `guacd-hostname` property would be transformed to `GUACD_HOSTNAME` when
  searching the environment.

`extension-priority`
: A comma-separated list of the namespaces of all extensions that should be
  loaded in a specific order. The special value `*` can be used in lieu of a
  namespace to represent all extensions that are not listed. All extensions
  explicitly listed will be sorted in the order given, while all extensions
  not explicitly listed will be sorted by their filenames.

  For example, to ensure support for SAML is loaded _first_:

  ```
  extension-priority: saml
  ```

  Or to ensure support for SAML is loaded _last_:

  ```
  extension-priority: *, saml
  ```

  If unsure which namespaces apply or the order that your extensions are
  loaded, check the Guacamole logs. The namespaces and load order of all
  installed extensions are logged by Guacamole during startup:

  ```
  ...
  23:32:06.467 [main] INFO  o.a.g.extension.ExtensionModule - Multiple extensions are installed and will be loaded in order of decreasing priority:
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [postgresql] "PostgreSQL Authentication" (/etc/guacamole/extensions/guacamole-auth-jdbc-postgresql-1.4.0.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [ldap] "LDAP Authentication" (/etc/guacamole/extensions/guacamole-auth-ldap-1.4.0.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [openid] "OpenID Authentication Extension" (/etc/guacamole/extensions/guacamole-auth-sso-openid-1.4.0.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [saml] "SAML Authentication Extension" (/etc/guacamole/extensions/guacamole-auth-sso-saml-1.4.0.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule - To change this order, set the "extension-priority" property or rename the extension files. The default priority of extensions is dictated by the sort order of their filenames.
  ...
  ```

`guacd-hostname`
: The host the Guacamole proxy daemon (guacd) is listening on. If omitted,
  Guacamole will assume guacd is listening on localhost.

`guacd-port`
: The port the Guacamole proxy daemon (guacd) is listening on. If omitted,
  Guacamole will assume guacd is listening on port 4822.

`guacd-ssl`
: If set to "true", Guacamole will require SSL/TLS encryption between the
  web application and guacd. By default, communication between the web
  application and guacd will be unencrypted.

  Note that if you enable this option, you must also configure guacd to use
  SSL via command line options. These options are documented in the manpage
  of guacd. You will need an SSL certificate and private key.

`skip-if-unavailable`
: A comma-separated list of the identifiers of authentication providers that
  should be allowed to fail internally without aborting the authentication
  process. For example, to request that Guacamole ignore failures due to the
  LDAP directory or MySQL server being unexpectedly down, allowing other
  authentication providers to continue functioning:

  ```
  skip-if-unavailable: mysql, ldap
  ```

  By default, Guacamole takes a conservative approach to internal failures,
  aborting the authentication process if an internal error occurs within any
  authentication provider. Depending on the nature of the error, this may
  mean that no users can log in until the cause of the failure is dealt
  with. The `skip-if-unavailable` property may be used to explicitly inform
  Guacamole that one or more underlying systems are expected to occasionally
  experience failures, and that other functioning systems should be relied
  upon if they do fail.

A typical `guacamole.properties` that defines explicit values for the
`guacd-hostname` and `guacd-port` properties would look like:

```
# Hostname and port of guacamole proxy
guacd-hostname: localhost
guacd-port:     4822
```

(webapp-logging)=

Logging within the web application
----------------------------------

By default, Guacamole logs all messages to the console. Servlet containers like
Tomcat will automatically redirect these messages to a log file, `catalina.out`
in the case of Tomcat, which you can read through while Guacamole runs.
Messages are logged at four different log levels, depending on message
importance and severity:

`error`
: Errors are fatal conditions. An operation, described in the log message,
  was attempted but could not proceed, and the failure of this operation is
  a serious problem that needs to be addressed.

`warn`
: Warnings are generally non-fatal conditions. The operation continued, but
  encountered noteworthy problems.

`info`
: "Info" messages are purely informational. They may be useful or
  interesting to administrators, but are not generally critical to proper
  operation of a Guacamole server.

`debug`
: Debug messages are highly detailed and oriented toward development. Most
  debug messages will contain stack traces and internal information that is
  useful when investigating problems within code. It is expected that debug
  messages, though verbose, will not affect performance.

`trace`
: Trace messages are similar to debug messages in intent and verbosity, but
  are so low-level that they may affect performance due to their frequency.
  Trace-level logging is rarely necessary, and is mainly useful in providing
  highly detailed context around issues being investigated.

Guacamole logs messages using a logging framework called
[Logback](http://logback.qos.ch/) and, by default, will only log messages at
the "`info`" level or higher. If you wish to change the log level, or configure
how or where Guacamole logs messages, you can do so by providing your own
`logback.xml` file within `GUACAMOLE_HOME`.  For example, to log all messages
to the console, even "`debug`" messages, you might use the following
`logback.xml`:

```xml
<configuration>

    <!-- Appender for debugging -->
    <appender name="GUAC-DEBUG" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <!-- Log at DEBUG level -->
    <root level="debug">
        <appender-ref ref="GUAC-DEBUG"/>
    </root>

</configuration>
```

Guacamole and the above example configure only one appender which logs to the
console, but Logback is extremely flexible and allows any number of appenders
which can each log to separate files, the console, etc.  based on a number of
criteria, including the log level and the source of the message.

More thorough [documentation on configuring
Logback](http://logback.qos.ch/manual/configuration.html) is provided on the
Logback project's web site.

(basic-auth)=

Using the default authentication
--------------------------------

Guacamole's default authentication module is simple and consists of a mapping
of usernames to configurations. This authentication module comes with Guacamole
and simply reads usernames and passwords from an XML file. It is always
enabled, but will only read from the XML file if it exists, and is always last
in priority relative to any other authentication extensions.

There are other authentication modules available. The Guacamole project
provides database-backed authentication modules with the ability to manage
connections and users from the web interface, and other authentication modules
can be created using the extension API provided along with the Guacamole web
application, guacamole-ext.

(user-mapping)=

### `user-mapping.xml`

The default authentication provider used by Guacamole reads all username,
password, and configuration information from a file called the "user mapping"
located at `GUACAMOLE_HOME/user-mapping.xml`. An example of a user mapping file
is included with Guacamole, and looks something like this:

```xml
<user-mapping>

    <!-- Per-user authentication and config information -->
    <authorize username="USERNAME" password="PASSWORD">
        <protocol>vnc</protocol>
        <param name="hostname">localhost</param>
        <param name="port">5900</param>
        <param name="password">VNCPASS</param>
    </authorize>

    <!-- Another user, but using md5 to hash the password
         (example below uses the md5 hash of "PASSWORD") -->
    <authorize
            username="USERNAME2"
            password="319f4d26e3c536b5dd871bb2c52e3178"
            encoding="md5">

        <!-- First authorized connection -->
        <connection name="localhost">
            <protocol>vnc</protocol>
            <param name="hostname">localhost</param>
            <param name="port">5901</param>
            <param name="password">VNCPASS</param>
        </connection>

        <!-- Second authorized connection -->
        <connection name="otherhost">
            <protocol>vnc</protocol>
            <param name="hostname">otherhost</param>
            <param name="port">5900</param>
            <param name="password">VNCPASS</param>
        </connection>

    </authorize>

</user-mapping>
```

Each user is specified with a corresponding `<authorize>` tag. This tag
contains all authorized connections for that user, each denoted with a
`<connection>` tag. Each `<connection>` tag contains a corresponding protocol
and set of protocol-specific parameters, specified with the `<protocol>` and
`<param>` tags respectively.

(user-setup)=

#### Adding users

When using `user-mapping.xml`, username/password pairs are specified with
`<authorize>` tags, which each have a `username` and `password` attribute. Each
`<authorize>` tag authorizes a specific username/password pair to access all
connections within the tag:

```xml
<authorize username="USER" password="PASS">
    ...
</authorize>
```

In the example above, the password would be listed in plaintext. If you don't
want to do this, you can also specify your password hashed with MD5:

```xml
<authorize username="USER"
           password="319f4d26e3c536b5dd871bb2c52e3178"
           encoding="md5">
    ...
</authorize>
```

After modifying `user-mapping.xml`, the file will be automatically reread by
Guacamole, and your changes will take effect immediately. The newly-added user
will be able to log in - no restart of the servlet container is needed.

(connection-setup)=

#### Adding connections to a user

To specify a connection within an `<authorize>` tag, you can either list a
single protocol and set of parameters (specified with a `<protocol>` tag and
any number of `<param>` tags), in which case that user will have access to only
one connection named "DEFAULT", or you can specify one or more connections with
one or more `<connection>` tags, each of which can be named and contains a
`<protocol>` tag and any number of `<param>` tags.

(connection-configuration)=

Configuring connections
-----------------------

Each protocol supported by Guacamole has its own set of configuration
parameters. These parameters typically describe the hostname and port of the
remote desktop server, the credentials to use when connecting, if any, and the
size and color depth of the display. If the protocol supports file transfer,
options for enabling that functionality will be provided as well.

### VNC

The VNC protocol is the simplest and first protocol supported by Guacamole.
Although generally not as fast as RDP, many VNC servers are adequate, and VNC
over Guacamole tends to be faster than VNC by itself due to decreased bandwidth
usage.

VNC support for Guacamole is provided by the libguac-client-vnc library, which
will be installed as part of guacamole-server if the required dependencies are
present during the build.

:::{note}
In addition to the VNC-specific parameters below, Guacamole's VNC support also
accepts the parameters of several features that Guacamole provides for multiple
protocols:

* [](disable-clipboard)
* [](common-sftp)
* [](graphical-recording)
* [](wake-on-lan)
:::

(vnc-network-parameters)=

#### Network parameters

With the exception of reverse-mode VNC connections, VNC works by making
outbound network connections to a particular host which runs one or more VNC
servers. Each VNC server is associated with a display number, from which the
appropriate port number is derived.

`hostname`
: The hostname or IP address of the VNC server Guacamole should connect to.

`port`
: The port the VNC server is listening on, usually 5900 or 5900 + display
  number. For example, if your VNC server is serving display number 1
  (sometimes written as `:1`), your port number here would be 5901.

`autoretry`
: The number of times to retry connecting before giving up and returning an
  error. In the case of a reverse connection, this is the number of times
  the connection process is allowed to time out.

(vnc-authentication)=

#### Authentication

The VNC standard defines only password based authentication. Other
authentication mechanisms exist, but are non-standard or proprietary.
Guacamole currently supports both standard password-only based authentication,
as well as username and password authentication.

`username`
: The username to use when attempting authentication, if any. This parameter
  is optional.

`password`
: The password to use when attempting authentication, if any. This parameter
  is optional.

(vnc-display-settings)=

#### Display settings

VNC servers do not allow the client to request particular display sizes, so you
are at the mercy of your VNC server with respect to display width and height.
However, to reduce bandwidth usage, you may request that the VNC server reduce
its color depth. Guacamole will automatically detect 256-color images, but this
can be guaranteed for absolutely all graphics sent over the connection by
forcing the color depth to 8-bit. Color depth is otherwise dictated by the VNC
server.

If you are noticing problems with your VNC display, such as the lack of a mouse
cursor, the presence of multiple mouse cursors, or strange colors (such as blue
colors appearing more like orange or red), these are typically the result of
bugs or limitations within the VNC server, and additional parameters are
available to work around such issues.

`color-depth`
: The color depth to request, in bits-per-pixel. This parameter is optional.
  If specified, this must be either 8, 16, 24, or 32. Regardless of what
  value is chosen here, if a particular update uses less than 256 colors,
  Guacamole will always send that update as a 256-color PNG.

`swap-red-blue`
: If the colors of your display appear wrong (blues appear orange or red,
  etc.), it may be that your VNC server is sending image data incorrectly,
  and the red and blue components of each color are swapped. If this is the
  case, set this parameter to "true" to work around the problem. This
  parameter is optional.

`cursor`
: If set to "remote", the mouse pointer will be rendered remotely, and the
  local position of the mouse pointer will be indicated by a small dot. A
  remote mouse cursor will feel slower than a local cursor, but may be
  necessary if the VNC server does not support sending the cursor image to
  the client.

`encodings`
: A space-delimited list of VNC encodings to use. The format of this
  parameter is dictated by libvncclient and thus doesn't really follow the
  form of other Guacamole parameters. This parameter is optional, and
  libguac-client-vnc will use any supported encoding by default.

  Beware that this parameter is intended to be replaced with individual,
  encoding-specific parameters in a future release.

`read-only`
: Whether this connection should be read-only. If set to "true", no input
  will be accepted on the connection at all. Users will only see the desktop
  and whatever other users using that same desktop are doing. This parameter
  is optional.

`force-lossless`
: Whether this connection should only use lossless compression for graphical
  updates. If set to "true", lossy compression will not be used. This
  parameter is optional. By default, lossy compression will be used when
  heuristics determine that it would likely outperform lossless compression.

#### VNC Repeater

There exist VNC repeaters, such as UltraVNC Repeater, which act as
intermediaries or proxies, providing a single logical VNC connection which is
then routed to another VNC server elsewhere. Additional parameters are required
to select which VNC host behind the repeater will receive the connection.

`dest-host`
: The destination host to request when connecting to a VNC proxy such as
  UltraVNC Repeater. This is only necessary if the VNC proxy in use requires
  the connecting user to specify which VNC server to connect to. If the VNC
  proxy automatically connects to a specific server, this parameter is not
  necessary.

`dest-port`
: The destination port to request when connecting to a VNC proxy such as
  UltraVNC Repeater. This is only necessary if the VNC proxy in use requires
  the connecting user to specify which VNC server to connect to. If the VNC
  proxy automatically connects to a specific server, this parameter is not
  necessary.

(vnc-reverse-connections)=

#### Reverse VNC connections

Guacamole supports "reverse" VNC connections, where the VNC client listens for
an incoming connection from the VNC server. When reverse VNC connections are
used, the VNC client and server switch network roles, but otherwise function as
they normally would. The VNC server still provides the remote display, and the
VNC client still provides all keyboard and mouse input.

`reverse-connect`
: Whether reverse connection should be used. If set to "true", instead of
  connecting to a server at a given hostname and port, guacd will listen on
  the given port for inbound connections from a VNC server.

`listen-timeout`
: If reverse connection is in use, the maximum amount of time to wait for an
  inbound connection from a VNC server, in milliseconds. If blank, the
  default value is 5000 (five seconds).

(vnc-audio)=

#### Audio support (via PulseAudio)

VNC does not provide its own support for audio, but Guacamole's VNC support can
obtain audio through a secondary network connection to a PulseAudio server
running on the same machine as the VNC server.

Most Linux systems provide audio through a service called PulseAudio.  This
service is capable of communicating over the network, and if PulseAudio is
configured to allow TCP connections, Guacamole can connect to your PulseAudio
server and combine its audio with the graphics coming over VNC.

Configuring PulseAudio for network connections requires an additional line
within the PulseAudio configuration file, usually `/etc/pulse/default.pa`:

```
load-module module-native-protocol-tcp auth-ip-acl=192.168.1.0/24 auth-anonymous=1
```

This loads the TCP module for PulseAudio, configuring it to accept connections
without authentication and *only* from the `192.168.1.0/24` subnet. You will
want to replace this value with the subnet or IP address from which guacd will
be connecting. It is possible to allow connections from absolutely anywhere,
but beware that you should only do so if the nature of your network prevents
unauthorized access:

```
load-module module-native-protocol-tcp auth-anonymous=1
```

In either case, the `auth-anonymous=1` parameter is strictly required.
Guacamole does not currently support the cookie-based authentication used by
PulseAudio for non-anonymous connections. If this parameter is omitted,
Guacamole will not be able to connect to PulseAudio.

Once the PulseAudio configuration file has been modified appropriately, restart
the PulseAudio service. PulseAudio should then begin listening on port 4713
(the default PulseAudio port) for incoming TCP connections. You can verify this
using a utility like {command}`netstat`:

```console
$ netstat -ln | grep 4713
tcp        0      0 0.0.0.0:4713            0.0.0.0:*               LISTEN
tcp6       0      0 :::4713                 :::*                    LISTEN
$
```

The following parameters are available for configuring the audio support for
VNC:

`enable-audio`
: If set to "true", audio support will be enabled, and a second connection
  for PulseAudio will be made in addition to the VNC connection. By default,
  audio support within VNC is disabled.

`audio-servername`
: The name of the PulseAudio server to connect to. This will be the hostname
  of the computer providing audio for your connection via PulseAudio, most
  likely the same as the value given for the `hostname` parameter.

  If this parameter is omitted, the default PulseAudio device will be used,
  which will be the PulseAudio server running on the same machine as guacd.

(vnc-clipboard-encoding)=

#### Clipboard encoding

While Guacamole will always use UTF-8 for its own clipboard data, the VNC
standard requires that clipboard data be encoded in ISO 8859-1. As most VNC
servers will not accept data in any other format, Guacamole will translate
between UTF-8 and ISO 8859-1 when exchanging clipboard data with the VNC
server, but this behavior can be overridden with the `clipboard-encoding`
parameter.

:::{important}
*The only clipboard encoding guaranteed to be supported by VNC servers is ISO
8859-1.* You should only override the clipboard encoding using the
`clipboard-encoding` parameter of you are absolutely positive your VNC server
supports other encodings.
:::

`clipboard-encoding`
: The encoding to assume for the VNC clipboard. This parameter is optional.
  By default, the standard encoding ISO 8859-1 will be used. *Only use this
  parameter if you are sure your VNC server supports other encodings beyond
  the standard ISO 8859-1.*

  Possible values are:

  ISO8859-1
  : ISO 8859-1 is the clipboard encoding mandated by the VNC standard, and
    supports only basic Latin characters. Unless your VNC server specifies
    otherwise, this encoding is the only encoding guaranteed to work.

  UTF-8
  : UTF-8 - the most common encoding used for Unicode. Using this encoding
    for the VNC clipboard violates the VNC specification, but some servers
    do support this. This parameter value should only be used if you know
    your VNC server supports this encoding.

  UTF-16
  : UTF-16 - a 16-bit encoding for Unicode which is not as common as UTF-8,
    but still widely used. Using this encoding for the VNC clipboard
    violates the VNC specification. This parameter value should only be used
    if you know your VNC server supports this encoding.

  CP1252
  : Code page 1252 - a Windows-specific encoding for Latin characters which
    is mostly a superset of ISO 8859-1, mapping some additional displayable
    characters onto what would otherwise be control characters. Using this
    encoding for the VNC clipboard violates the VNC specification. This
    parameter value should only be used if you know your VNC server supports
    this encoding.

(adding-vnc)=

#### Adding a VNC connection

If you are using the default authentication built into Guacamole, and you wish
to grant access to a VNC connection to a particular user, you need to locate
the `<authorize>` section for that user within your `user-mapping.xml`, and add
a section like the following within it:

```xml
<connection name="Unique Name">
    <protocol>vnc</protocol>
    <param name="hostname">localhost</param>
    <param name="port">5901</param>
</connection>
```

If added exactly as above, a new connection named "`Unique Name`" will be
available to the user associated with the `<authorize>` section containing it.
The connection will use VNC to connect to localhost at port 5901. Naturally,
you will want to change some or all of these values.

If your VNC server requires a password, or you wish to specify other
configuration parameters (to reduce the color depth, for example), you will
need to add additional `<param>` tags accordingly.

Other authentication methods will provide documentation describing how to
configure new connections. If the authentication method in use fully implements
the features of Guacamole's authentication API, you will be able to add a new
VNC connection easily and intuitively using the administration interface built
into Guacamole. You will not need to edit configuration files.

(vnc-servers)=

#### Which VNC server?

The choice of VNC server can make a big difference when it comes to
performance, especially over slower networks. While many systems provide VNC
access by default, using this is often not the fastest method.

(realvnc)=

##### RealVNC or TigerVNC

RealVNC, and its derivative TigerVNC, perform quite well. In our testing, they
perform the best with Guacamole. If you are okay with having a desktop that can
only be accessed via VNC, one of these is likely your best choice. Both
optimize window movement and (depending on the application) scrolling, giving a
very responsive user experience.

##### TightVNC

TightVNC is widely-available and performs generally as well as RealVNC or
TigerVNC. If you wish to use TightVNC with Guacamole, performance should be
just fine, but we highly recommend disabling its JPEG encoding. This is because
images transmitted to Guacamole are always encoded losslessly as PNG images.
When this operation is performed on a JPEG image, the artifacts present from
JPEG's lossy compression reduce the compressibility of the image for PNG, thus
leading to a slower experience overall than if JPEG was simply not used to
begin with.

##### x11vnc

The main benefit of using x11vnc is that it allows you to continue using your
desktop normally, while simultaneously exposing control of your desktop via
VNC. Performance of x11vnc is comparable to RealVNC, TigerVNC, and TightVNC. If
you need to use your desktop locally as well as via VNC, you will likely be
quite happy with x11vnc.

##### vino

vino is the VNC server that comes with the Gnome desktop environment, and is
enabled if you enable "desktop sharing" via the system preferences available
within Gnome. If you need to share your local desktop, we recommend using
x11vnc rather vino, as it has proven more performant and feature-complete in
our testing. If you don't need to share a local desktop but simply need an
environment you can access remotely, using a VNC server like RealVNC, TigerVNC,
or TightVNC is a better choice.

(qemu)=

##### QEMU or KVM

QEMU (and thus KVM) expose the displays of virtual machines using VNC.  If you
need to see the virtual monitor of your virtual machine, using this VNC
connection is really your only choice. As the VNC server built into QEMU cannot
be aware of higher-level operations like window movement, resizing, or
scrolling, those operations will tend to be sent suboptimally, and will not be
as fast as a VNC server running within the virtual machine.

If you wish to use a virtual machine for desktop access, we recommend
installing a native VNC server inside the virtual machine after the virtual
machine is set up. This will give a more responsive desktop.

### RDP

The RDP protocol is more complicated than VNC and was the second protocol
officially supported by Guacamole. RDP tends to be faster than VNC due to the
use of caching, which Guacamole does take advantage of.

RDP support for Guacamole is provided by the libguac-client-rdp library, which
will be installed as part of guacamole-server if the required dependencies are
present during the build.

:::{note}
In addition to the RDP-specific parameters below, Guacamole's RDP support also
accepts the parameters of several features that Guacamole provides for multiple
protocols:

* [](disable-clipboard)
* [](common-sftp)
* [](graphical-recording)
* [](wake-on-lan)
:::

(rdp-network-parameters)=

#### Network parameters

RDP connections require a hostname or IP address defining the
destination machine. The RDP port is defined to be 3389, and will be
this value in most cases. You only need to specify the RDP port if you
are not using port 3389.

`hostname`
: The hostname or IP address of the RDP server Guacamole should connect to.

`port`
: The port the RDP server is listening on. This parameter is optional. If
  this is not specified, the standard port for RDP (3389) or Hyper-V's
  default port for VMConnect (2179) will be used, depending on the security
  mode selected.

(rdp-authentication)=

#### Authentication and security

RDP provides authentication through the use of a username, password, and
optional domain. All RDP connections are encrypted.

Most RDP servers will provide a graphical login if the username, password, and
domain parameters are omitted. One notable exception to this is Network Level
Authentication, or NLA, which performs all authentication outside of a desktop
session, and thus in the absence of a graphical interface.

Servers that require NLA can be handled by Guacamole in one of two ways. The
first is to provide the username and password within the connection
configuration, either via static values or by passing through the Guacamole
credentials with [parameter tokens](parameter-tokens) and [](ldap-auth).
Alternatively, if credentials are not configured within the connection
configuration, Guacamole will attempt to prompt the user for the credentials
interactively, if the versions of both guacd and Guacamole Client in use
support it. If either component does not support prompting and the credentials
are not configured, NLA-based connections will fail.

`username`
: The username to use to authenticate, if any. This parameter is optional.

`password`
: The password to use when attempting authentication, if any. This parameter
  is optional.

`domain`
: The domain to use when attempting authentication, if any. This parameter
  is optional.

`security`
: The security mode to use for the RDP connection. This mode dictates how
  data will be encrypted and what type of authentication will be performed,
  if any. By default, a security mode is selected based on a negotiation
  process which determines what both the client and the server support.

  Possible values are:

  any
  : Automatically select the security mode based on the security protocols
    supported by both the client and the server. *This is the default*.

  nla
  : Network Level Authentication, sometimes also referred to as "hybrid" or
    CredSSP (the protocol that drives NLA). This mode uses TLS encryption
    and requires the username and password to be given in advance. Unlike
    RDP mode, the authentication step is performed before the remote desktop
    session actually starts, avoiding the need for the Windows server to
    allocate significant resources for users that may not be authorized.

    If the versions of guacd and Guacamole Client in use support prompting
    and the username, password, and domain are not specified, the user will
    be interactively prompted to enter credentials to complete NLA and
    continue the connection. Otherwise, when prompting is not supported and
    credentials are not provided, NLA connections will fail.

  nla-ext
  : Extended Network Level Authentication. This mode is identical to NLA
    except that an additional "[Early User Authorization
    Result](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-rdpbcgr/d0e560a3-25cb-4563-8bdc-6c4cc625bbfc)"
    is required to be sent from the server to the client immediately after the
    NLA handshake is completed.

  tls
  : RDP authentication and encryption implemented via TLS (Transport Layer
    Security). Also referred to as RDSTLS, the TLS security mode is
    primarily used in load balanced configurations where the initial RDP
    server may redirect the connection to a different RDP server.

  vmconnect
  : Automatically select the security mode based on the security protocols
    supported by both the client and the server, limiting that negotiation
    to only the protocols known to be supported by [Hyper-V /
    VMConnect](rdp-preconnection-pdu).

  rdp
  : Legacy RDP encryption. This mode is generally only used for older
    Windows servers or in cases where a standard Windows login screen is
    desired. Newer versions of Windows have this mode disabled by default
    and will only accept NLA unless explicitly configured otherwise.

`ignore-cert`
: If set to "true", the certificate returned by the server will be ignored,
  even if that certificate cannot be validated. This is useful if you
  universally trust the server and your connection to the server, and you
  know that the server's certificate cannot be validated (for example, if it
  is self-signed).

`disable-auth`
: If set to "true", authentication will be disabled. Note that this refers
  to authentication that takes place while connecting. Any authentication
  enforced by the server over the remote desktop session (such as a login
  dialog) will still take place. By default, authentication is enabled and
  only used when requested by the server.

  If you are using NLA, authentication must be enabled by definition.

(rdp-clipboard-normalization)=

#### Clipboard normalization

Windows uses a different sequence of characters at the end of each line
compared to other operating systems. As RDP preserves the format of line
endings within the clipboard, this can cause trouble when using a non-Windows
machine to access Windows or vice versa.

If clipboard normalization is used, Guacamole will automatically translate the
line endings within clipboard data to compensate for the expectations of the
remote system.

`normalize-clipboard`
: The type of line ending normalization to apply to text within the clipboard,
  if any. By default, line ending normalization is not applied.

  Possible values are:

  preserve
  : Preserve all line endings within the clipboard exactly as they are,
    performing no normalization whatsoever. This is the default.

  unix
  : Automatically transform all line endings within the clipboard to Unix-style
    line endings (LF). This format of line ending is the format used by both
    Linux and Mac.

  windows
  : Automatically transform all line endings within the clipboard to
    Windows-style line endings (CRLF).

(rdp-session-settings)=

#### Session settings

RDP sessions will typically involve the full desktop environment of a normal
user. Alternatively, you can manually specify a program to use instead of the
RDP server's default shell, or connect to the administrative console.

Although Guacamole is independent of keyboard layout, RDP is not. This is
because Guacamole represents keys based on what they *do* ("press the Enter
key"), while RDP uses identifiers based on the key's location ("press the
rightmost key in the second row"). To translate between a Guacamole key event
and an RDP key event, Guacamole must know ahead of time the keyboard layout of
the RDP server.

By default, the US English qwerty keyboard will be used. If this does not match
the keyboard layout of your RDP server, keys will not be properly translated,
and you will need to explicitly choose a different layout in your connection
settings. If your keyboard layout is not supported, please notify the Guacamole
team by [opening an issue in
JIRA](https://issues.apache.org/jira/browse/GUACAMOLE).


`client-name`
: When connecting to the RDP server, Guacamole will normally provide its own
  hostname as the name of the client. If this parameter is specified,
  Guacamole will use its value instead.

  On Windows RDP servers, this value is exposed within the session as the
  `CLIENTNAME` environment variable.

`console`
: If set to "true", you will be connected to the console (admin) session of
  the RDP server.

`initial-program`
: The full path to the program to run immediately upon connecting. This
  parameter is optional.

`server-layout`
: The server-side keyboard layout. This is the layout of the RDP server and
  has nothing to do with the keyboard layout in use on the client. *The
  Guacamole client is independent of keyboard layout.* The RDP protocol,
  however, is *not* independent of keyboard layout, and Guacamole needs to
  know the keyboard layout of the server in order to send the proper keys
  when a user is typing.

  Possible values are generally in the format
  {samp}`{LANGUAGE}-{REGION}-{VARIANT}`, where `LANGUAGE` is the standard
  two-letter language code for the primary language associated with the
  layout, `REGION` is a standard representation of the location that the
  keyboard is used (the two-letter country code, when possible), and
  `VARIANT` is the specific keyboard layout variant (such as "qwerty",
  "qwertz", or "azerty"):

  | Keyboard layout                | Parameter value        |
  | ------------------------------ | ---------------------- |
  | Brazilian (Portuguese)         | `pt-br-qwerty`         |
  | English (UK)                   | `en-gb-qwerty`         |
  | English (US)                   | `en-us-qwerty`         |
  | French                         | `fr-fr-azerty`         |
  | French (Belgian)               | `fr-be-azerty`         |
  | French (Swiss)                 | `fr-ch-qwertz`         |
  | German                         | `de-de-qwertz`         |
  | German (Swiss)                 | `de-ch-qwertz`         |
  | Hungarian                      | `hu-hu-qwertz`         |
  | Italian                        | `it-it-qwerty`         |
  | Japanese                       | `ja-jp-qwerty`         |
  | Norwegian                      | `no-no-qwerty`         |
  | Spanish                        | `es-es-qwerty`         |
  | Spanish (Latin American)       | `es-latam-qwerty`      |
  | Swedish                        | `sv-se-qwerty`         |
  | Turkish-Q                      | `tr-tr-qwerty`         |

  If you server's keyboard layout is not yet supported, and it is not possible
  to set your server to use a supported layout, the `failsafe` layout may be used
  to force Unicode events to be used for all input, however beware that doing so
  may prevent keyboard shortcuts from working as expected.

`timezone`
: The timezone that the client should send to the server for configuring the
  local time display of that server. The format of the timezone is in the
  standard IANA key zone format, which is the format used in UNIX/Linux.
  This will be converted by RDP into the correct format for Windows.

  The timezone is detected and will be passed to the server during the
  handshake phase of the connection, and may used by protocols, like RDP,
  that support it. This parameter can be used to override the value detected
  and passed during the handshake, or can be used in situations where guacd
  does not support passing the timezone parameter during the handshake phase
  (guacd versions prior to 1.3.0).

  Support for forwarding the client timezone varies by RDP server
  implementation. For example, with Windows, support for forwarding
  timezones is only present in Windows Server with Remote Desktop Services
  (RDS, formerly known as Terminal Services) installed. Windows Server
  installations in admin mode, along with Windows workstation versions, do
  not allow the timezone to be forwarded. Other server implementations, for
  example, xrdp, may not implement this feature at all. Consult the
  documentation for the RDP server to determine whether or not this feature
  is supported.

(rdp-display-settings)=

#### Display settings

Guacamole will automatically choose an appropriate display size for RDP
connections based on the size of the browser window and the DPI of the device.
The size of the display can be forced by specifying explicit width or height
values.

To reduce bandwidth usage, you may also request that the server reduce its
color depth. Guacamole will automatically detect 256-color images, but this can
be guaranteed for absolutely all graphics sent over the connection by forcing
the color depth to 8-bit. Color depth is otherwise dictated by the RDP server.

`color-depth`
: The color depth to request, in bits-per-pixel. This parameter is optional.
  If specified, this must be either 8, 16, or 24. Regardless of what value
  is chosen here, if a particular update uses less than 256 colors,
  Guacamole will always send that update as a 256-color PNG.

`width`
: The width of the display to request, in pixels. This parameter is
  optional. If this value is not specified, the width of the connecting
  client display will be used instead.

`height`
: The height of the display to request, in pixels. This parameter is
  optional. If this value is not specified, the height of the connecting
  client display will be used instead.

`dpi`
: The desired effective resolution of the client display, in DPI. This
  parameter is optional. If this value is not specified, the resolution and
  size of the client display will be used together to determine,
  heuristically, an appropriate resolution for the RDP session.

`resize-method`
: The method to use to update the RDP server when the width or height of the
  client display changes. This parameter is optional. If this value is not
  specified, no action will be taken when the client display changes size.

  Normally, the display size of an RDP session is constant and can only be
  changed when initially connecting. As of RDP 8.1, the "Display Update"
  channel can be used to request that the server change the display size.
  For older RDP servers, the only option is to disconnect and reconnect with
  the new size.

  Possible values are:

  display-update
  : Uses the "Display Update" channel added with RDP 8.1 to signal the
    server when the client display size has changed.

  reconnect
  : Automatically disconnects the RDP session when the client display size
    has changed, and reconnects with the new size.

`force-lossless`
: Whether this connection should only use lossless compression for graphical
  updates. If set to "true", lossy compression will not be used. This
  parameter is optional. By default, lossy compression will be used when
  heuristics determine that it would likely outperform lossless compression.

(rdp-device-redirection)=

#### Device redirection

Device redirection refers to the use of non-display devices over RDP.
Guacamole's RDP support currently allows redirection of audio, printing, and
disk access, some of which require additional configuration in order to
function properly.

Audio redirection will be enabled by default. If Guacamole was correctly
installed, and audio redirection is supported by your RDP server, sound should
play within remote connections without manual intervention.

Printing requires GhostScript to be installed on the Guacamole server, and
allows users to print arbitrary documents directly to PDF. When documents are
printed to the redirected printer, the user will receive a PDF of that document
within their web browser.

Guacamole provides support for file transfer over RDP by emulating a virtual
disk drive. This drive will persist on the Guacamole server, confined within
the drive path specified. If drive redirection is enabled on a Guacamole RDP
connection, users will be able to upload and download files as described in
[](using-guacamole).

`disable-audio`
: Audio is enabled by default in both the client and in libguac-client-rdp.
  If you are concerned about bandwidth usage, or sound is causing problems,
  you can explicitly disable sound by setting this parameter to "true".

`enable-audio-input`
: If set to "true", audio input support (microphone) will be enabled,
  leveraging the standard "`AUDIO_INPUT`" channel of RDP. By default, audio
  input support within RDP is disabled.

`enable-touch`
: If set to "true", support for multi-touch events will be enabled, leveraging
  the standard "`RDPEI`" channel of RDP. By default, direct RDP support for
  multi-touch events is disabled.

  Enabling support for multi-touch allows touch interaction with applications
  inside the RDP session, however the touch gestures available will depend on
  the level of touch support of those applications and the OS.

  If multi-touch support is not enabled, pointer-type interaction with
  applications inside the RDP session will be limited to mouse or emulated
  mouse events.

`enable-printing`
: Printing is disabled by default, but with printing enabled, RDP users can
  print to a virtual printer that sends a PDF containing the document
  printed to the Guacamole client. Enable printing by setting this parameter
  to "true".

  *Printing support requires GhostScript to be installed.* If guacd cannot
  find the `gs` executable when printing, the print attempt will fail.

`printer-name`
: The name of the redirected printer device that is passed through to the
  RDP session. This is the name that the user will see in, for example, the
  Devices and Printers control panel.

  If printer redirection is not enabled, this option has no effect.

`enable-drive`
: File transfer is disabled by default, but with file transfer enabled, RDP
  users can transfer files to and from a virtual drive which persists on the
  Guacamole server. Enable file transfer support by setting this parameter
  to "true".

  Files will be stored in the directory specified by the "`drive-path`"
  parameter, which is required if file transfer is enabled.

`disable-download`
: If set to true downloads from the remote server to client (browser) will
  be disabled. This includes both downloads done via the hidden Guacamole
  menu, as well as using the special "Download" folder presented to the
  remote server. The default is false, which means that downloads will be
  allowed.

  If file transfer is not enabled, this parameter is ignored.

`disable-upload`
: If set to true, uploads from the client (browser) to the remote server
  location will be disabled. The default is false, which means uploads will
  be allowed if file transfer is enabled.

  If file transfer is not enabled, this parameter is ignored.

`drive-name`
: The name of the filesystem used when passed through to the RDP session.
  This is the name that users will see in their Computer/My Computer area
  along with client name (for example, "Guacamole on Guacamole RDP"), and is
  also the name of the share when accessing the special `\\tsclient` network
  location.

  If file transfer is not enabled, this parameter is ignored.

`drive-path`
: The directory on the Guacamole server in which transferred files should be
  stored. This directory must be accessible by guacd and both readable and
  writable by the user that runs guacd. *This parameter does not refer to a
  directory on the RDP server.*

  If file transfer is not enabled, this parameter is ignored.

`create-drive-path`
: If set to "true", and file transfer is enabled, the directory specified by
  the `drive-path` parameter will automatically be created if it does not
  yet exist. Only the final directory in the path will be created - if other
  directories earlier in the path do not exist, automatic creation will
  fail, and an error will be logged.

  By default, the directory specified by the `drive-path` parameter will not
  automatically be created, and attempts to transfer files to a non-existent
  directory will be logged as errors.

  If file transfer is not enabled, this parameter is ignored.

`console-audio`
: If set to "true", audio will be explicitly enabled in the console (admin)
  session of the RDP server. Setting this option to "true" only makes sense
  if the `console` parameter is also set to "true".

`static-channels`
: A comma-separated list of static channel names to open and expose as
  pipes. If you wish to communicate between an application running on the
  remote desktop and JavaScript, this is the best way to do it. Guacamole
  will open an outbound pipe with the name of the static channel. If
  JavaScript needs to communicate back in the other direction, it should
  respond by opening another pipe with the same name.

  Guacamole allows any number of static channels to be opened, but protocol
  restrictions of RDP limit the size of each channel name to 7 characters.

(rdp-preconnection-pdu)=

#### Preconnection PDU (Hyper-V / VMConnect)

Some RDP servers host multiple logical RDP connections behind a single server
listening on a single TCP port. To select between these logical connections, an
RDP client must send the "preconnection PDU" - a message which contains values
that uniquely identify the destination, referred to as the "RDP source". This
mechanism is defined by the ["Session Selection
Extension](https://msdn.microsoft.com/en-us/library/cc242359.aspx) for the RDP
protocol, and is implemented by Microsoft's Hyper-V hypervisor.

If you are using Hyper-V, you will need to specify the ID of the destination
virtual machine within the `preconnection-blob` parameter.  This value can be
determined using PowerShell:

```ps1con
PS C:\> Get-VM VirtualMachineName | Select-Object Id

Id
--
ed272546-87bd-4db9-acba-e36e1a9ca20a


PS C:\>
```

The preconnection PDU is intentionally generic. While its primary use is as a
means for selecting virtual machines behind Hyper-V, other RDP servers may use
it as well. It is up to the RDP server itself to determine whether the
preconnection ID, BLOB, or both will be used, and what their values mean.

*If you do intend to use Hyper-V, beware that its built-in RDP server requires
different parameters for authentication and Guacamole's defaults will not
work.* In most cases, you will need to do the following when connecting to
Hyper-V:

1. Specify both "`username`" and "`password`" appropriately, and set
   "`security`" to "`vmconnect`". Selecting the "`vmconnect`" security mode
   will configure Guacamole to automatically negotiate security modes known to
   be supported by Hyper-V, and will automatically select Hyper-V's default RDP
   port (2179).

2. If necessary, set "`ignore-cert`" to "`true`". Hyper-V may use a self-signed
   certificate.

`preconnection-id`
: The numeric ID of the RDP source. This is a non-negative integer value
  dictating which of potentially several logical RDP connections should be
  used. This parameter is optional, and is only required if the RDP server
  is documented as requiring it. *If using Hyper-V, this should be left
  blank.*

`preconnection-blob`
: An arbitrary string which identifies the RDP source - one of potentially
  several logical RDP connections hosted by the same RDP server. This
  parameter is optional, and is only required if the RDP server is
  documented as requiring it, such as Hyper-V. In all cases, the meaning of
  this parameter is opaque to the RDP protocol itself and is dictated by the
  RDP server. *For Hyper-V, this will be the ID of the destination virtual
  machine.*

(rdp-gateway)=

#### Remote desktop gateway

Microsoft's remote desktop server provides an additional gateway service which
allows external connections to be forwarded to internal RDP servers which are
otherwise not accessible. If you will be using Guacamole to connect through
such a gateway, you will need to provide additional parameters describing the
connection to that gateway, as well as any required credentials.

`gateway-hostname`
: The hostname of the remote desktop gateway that should be used as an
  intermediary for the remote desktop connection. *If omitted, a gateway
  will not be used.*

`gateway-port`
: The port of the remote desktop gateway that should be used as an
  intermediary for the remote desktop connection. By default, this will be
  "443".

`gateway-username`
: The username of the user authenticating with the remote desktop gateway,
  if a gateway is being used. This is not necessarily the same as the user
  actually using the remote desktop connection.

`gateway-password`
: The password to provide when authenticating with the remote desktop
  gateway, if a gateway is being used.

`gateway-domain`
: The domain of the user authenticating with the remote desktop gateway, if
  a gateway is being used. This is not necessarily the same domain as the
  user actually using the remote desktop connection.

(rdp-connection-broker)=

#### Load balancing and RDP connection brokers

If your remote desktop servers are behind a load balancer, sometimes referred
to as a "connection broker" or "TS session broker", that balancer may require
additional information during the connection process to determine how the
incoming connection should be routed. RDP does not dictate the format of this
information; it is specific to the balancer in use.

If you are using a load balancer and are unsure whether such information is
required, *you will need to check the documentation for your balancer*. If your
balancer provides `.rdp` files for convenience, look through the contents of
those files for a string field called "loadbalanceinfo", as that field is where
the required information/cookie would be specified.

`load-balance-info`
: The load balancing information or cookie which should be provided to the
  connection broker. *If no connection broker is being used, this should be
  left blank.*

(rdp-perf-flags)=

#### Performance flags

RDP provides several flags which control the availability of features that
decrease performance and increase bandwidth for the sake of aesthetics, such as
wallpaper, window theming, menu effects, and smooth fonts. These features are
all disabled by default within Guacamole such that bandwidth usage is
minimized, but you can manually re-enable them on a per-connection basis if
desired.

`enable-wallpaper`
: If set to "true", enables rendering of the desktop wallpaper. By default,
  wallpaper will be disabled, such that unnecessary bandwidth need not be
  spent redrawing the desktop.

`enable-theming`
: If set to "true", enables use of theming of windows and controls. By
  default, theming within RDP sessions is disabled.

`enable-font-smoothing`
: If set to "true", text will be rendered with smooth edges. Text over RDP
  is rendered with rough edges by default, as this reduces the number of
  colors used by text, and thus reduces the bandwidth required for the
  connection.

`enable-full-window-drag`
: If set to "true", the contents of windows will be displayed as windows are
  moved. By default, the RDP server will only draw the window border while
  windows are being dragged.

`enable-desktop-composition`
: If set to "true", graphical effects such as transparent windows and
  shadows will be allowed. By default, such effects, if available, are
  disabled.

`enable-menu-animations`
: If set to "true", menu open and close animations will be allowed. Menu
  animations are disabled by default.

`disable-bitmap-caching`
: In certain situations, particularly with RDP server implementations with
  known bugs, it is necessary to disable RDP's built-in bitmap caching
  functionality. This parameter allows that to be controlled in a Guacamole
  session. If set to "true" the RDP bitmap cache will not be used.

`disable-offscreen-caching`
: RDP normally maintains caches of regions of the screen that are currently
  not visible in the client in order to accelerate retrieval of those
  regions when they come into view. This parameter, when set to "true," will
  disable caching of those regions. This is usually only useful when dealing
  with known bugs in RDP server implementations and should remain enabled in
  most circumstances.

`disable-glyph-caching`
: In addition to screen regions, RDP maintains caches of frequently used
  symbols or fonts, collectively known as "glyphs." As with bitmap and
  offscreen caching, certain known bugs in RDP implementations can cause
  performance issues with this enabled, and setting this parameter to "true"
  will disable that glyph caching in the RDP session.

  **Glyph caching is currently universally disabled, regardless of the value of
  this parameter, as glyph caching support is not considered stable by FreeRDP
  as of the FreeRDP 2.0.0 release. See: {jira}`GUACAMOLE-1191`.**

(rdp-remoteapp)=

#### RemoteApp

Recent versions of Windows provide a feature called RemoteApp which allows
individual applications to be used over RDP, without providing access to the
full desktop environment. If your RDP server has this feature enabled and
configured, you can configure Guacamole connections to use those individual
applications.

`remote-app`
: Specifies the RemoteApp to start on the remote desktop. If supported by
  your remote desktop server, this application, and only this application,
  will be visible to the user.

  Windows requires a special notation for the names of remote applications.
  The names of remote applications must be prefixed with two vertical bars.
  For example, if you have created a remote application on your server for
  `notepad.exe` and have assigned it the name "notepad", you would set this
  parameter to: "`||notepad`".

`remote-app-dir`
: The working directory, if any, for the remote application. This parameter
  has no effect if RemoteApp is not in use.

`remote-app-args`
: The command-line arguments, if any, for the remote application. This
  parameter has no effect if RemoteApp is not in use.

(adding-rdp)=

#### Adding an RDP connection

If you are using the default authentication built into Guacamole, and you wish
to grant access to a RDP connection to a particular user, you need to locate
the `<authorize>` section for that user within your `user-mapping.xml`, and add
a section like the following within it:

```xml
<connection name="Unique Name">
    <protocol>rdp</protocol>
    <param name="hostname">localhost</param>
    <param name="port">3389</param>
</connection>
```

If added exactly as above, a new connection named "`Unique Name`" will be
available to the user associated with the `<authorize>` section containing it.
The connection will use RDP to connect to localhost at port 3389.  Naturally,
you will want to change some or all of these values.

If you want to login automatically rather than receive a login prompt upon
connecting, you can specify a username and password with additional `<param>`
tags. Other options are available for controlling the color depth, size of the
screen, etc.

Other authentication methods will provide documentation describing how to
configure new connections. If the authentication method in use fully implements
the features of Guacamole's authentication API, you will be able to add a new
RDP connection easily and intuitively using the administration interface built
into Guacamole. You will not need to edit configuration files.

### SSH

Unlike VNC or RDP, SSH is a text protocol. Its implementation in Guacamole is
actually a combination of a terminal emulator and SSH client, because the SSH
protocol isn't inherently graphical. Guacamole's SSH support emulates a
terminal on the server side, and draws the screen of this terminal remotely on
the client.

SSH support for Guacamole is provided by the libguac-client-ssh library, which
will be installed as part of guacamole-server if the required dependencies are
present during the build.

:::{note}
In addition to the SSH-specific parameters below, Guacamole's SSH support also
accepts the parameters of several features that Guacamole provides for multiple
protocols:

* [](disable-clipboard)
* [](graphical-recording)
* [](typescripts)
* [](stdin-pipe)
* [](terminal-behavior)
* [](terminal-display-settings)
* [](wake-on-lan)
:::

(ssh-host-verification)=

#### SSH Host Verification

By default, Guacamole does not do any verification of host identity before
establishing SSH connections. While this may be safe for private and trusted
networks, it is not ideal for large networks with unknown/untrusted systems, or
for SSH connections that traverse the Internet. The potential exists for
Man-in-the-Middle (MitM) attacks when connecting to these hosts.

Guacamole includes two methods for verifying SSH (and SFTP) server identity
that can be used to make sure that the host you are connecting to is a host
that you know and trust. The first method is by reading a file in
`GUACAMOLE_HOME` called `ssh_known_hosts`. This file should be in the format of
a standard OpenSSH `known_hosts` file. If the file is not present, no
verification is done. If the file is present, it is read in at connection time
and remote host identities are verified against the keys present in the file.

The second method for verifying host identity is by passing a connection
parameter that contains an OpenSSH known hosts entry for that specific host.
The `host-key` parameter is used for SSH connections, while the SFTP
connections associated with RDP and VNC use the `sftp-host-key` parameter. If
these parameters are not present on their respective connections no host
identity verification is performed. If the parameter is present then the
identity of the remote host is verified against the identity provided in the
parameter before a connection is established.

(ssh-network-parameters)=

#### Network parameters

SSH connections require a hostname or IP address defining the destination
machine. SSH is standardized to use port 22 and this will be the proper value
in most cases. You only need to specify the SSH port if you are not using the
standard port.

`hostname`
: The hostname or IP address of the SSH server Guacamole should connect to.

`port`
: The port the SSH server is listening on, usually 22. This parameter is
  optional. If this is not specified, the default of 22 will be used.

`host-key`
: The known hosts entry for the SSH server. This parameter is optional, and,
  if not provided, no verification of host identity will be done. If the
  parameter is provided the identity of the server will be checked against
  the data.

  The format of this parameter is that of a single entry from an OpenSSH
  `known_hosts` file.

  For more information, please see [](ssh-host-verification).

`server-alive-interval`
: By default the SSH client does not send keepalive requests to the server.
  This parameter allows you to configure the the interval in seconds at
  which the client connection sends keepalive packets to the server. The
  default is 0, which disables sending the packets. The minimum value is 2.

(ssh-authentication)=

#### Authentication

SSH provides authentication through passwords and public key authentication,
and also supports the "NONE" method.

SSH "NONE" authentication is seen occasionally in appliances and items like
network or SAN fabric switches. Generally for this authentication method you
need only provide a username.

For Guacamole to use public key authentication, it must have access to your
private key and, if applicable, its passphrase. If the private key requires a
passphrase, but no passphrase is provided, you will be prompted for the
passphrase upon connecting.

If no private key is provided, Guacamole will attempt to authenticate using a
password, reading that password from the connection parameters, if provided, or
by prompting the user directly.

`username`
: The username to use to authenticate, if any. This parameter is optional.
  If not specified, you will be prompted for the username upon connecting.

`password`
: The password to use when attempting authentication, if any. This parameter
  is optional. If not specified, you will be prompted for your password upon
  connecting.

`private-key`
: The entire contents of the private key to use for public key
  authentication. If this parameter is not specified, public key
  authentication will not be used. The private key must be in OpenSSH
  format, as would be generated by the OpenSSH {command}`ssh-keygen`
  utility.

`passphrase`
: The passphrase to use to decrypt the private key for use in public key
  authentication. This parameter is not needed if the private key does not
  require a passphrase. If the private key requires a passphrase, but this
  parameter is not provided, the user will be prompted for the passphrase
  upon connecting.

(ssh-command)=

#### Running a command (instead of a shell)

By default, SSH sessions will start an interactive shell. The shell which will
be used is determined by the SSH server, normally by reading the user's default
shell previously set with `chsh` or within `/etc/passwd`. If you wish to
override this and instead run a specific command, you can do so by specifying
that command in the configuration of the Guacamole SSH connection.

`command`
: The command to execute over the SSH session, if any. This parameter is
  optional. If not specified, the SSH session will use the user's default
  shell.

#### Internationalization/Locale settings

The language of the session is normally set by the SSH server. If the SSH
server allows the relevant environment variable to be set, the language can be
overridden on a per-connection basis.

`locale`
: The specific locale to request for the SSH session. This parameter is
  optional and may be any value accepted by the `LANG` environment variable
  of the SSH server. If not specified, the SSH server's default locale will
  be used.

  As this parameter is sent to the SSH server using the `LANG` environment
  variable, the parameter will only have an effect if the SSH server allows
  the `LANG` environment variable to be set by SSH clients.

`timezone`
: This parameter allows you to control the timezone that is sent to the
  server over the SSH connection, which will change the way local time is
  displayed on the server.

  The mechanism used to do this over SSH connections is by setting the `TZ`
  variable on the SSH connection to the timezone specified by this
  parameter. This means that the SSH server must allow the `TZ` variable to
  be set/overriden - many SSH server implementations have this disabled by
  default. To get this to work, you may need to modify the configuration of
  the SSH server and explicitly allow for `TZ` to be set/overriden.

  The available values of this parameter are standard IANA key zone format
  timezones, and the value will be sent directly to the server in this
  format.

(ssh-sftp)=

#### SFTP

Guacamole provides support for file transfer over SSH using SFTP, the
file transfer protocol built into most SSH servers. If SFTP is enabled
on a Guacamole SSH connection, users will be able to upload and download
files as described in [](using-guacamole)

`enable-sftp`
: Whether file transfer should be enabled. If set to "true", the user will
  be allowed to upload or download files from the SSH server using SFTP.
  Guacamole includes the {program}`guacctl` utility which controls file
  downloads and uploads when run on the SSH server by the user over the SSH
  connection.

`sftp-root-directory`
: The directory to expose to connected users via Guacamole's [file
  browser](file-browser). If omitted, the root directory will be used by
  default.

`sftp-disable-download`
: If set to true downloads from the remote system to the client (browser)
  will be disabled. The default is false, which means that downloads will be
  enabled.

  If SFTP is not enabled, this parameter will be ignored.

`sftp-disable-upload`
: If set to true uploads from the client (browser) to the remote system will
  be disabled. The default is false, which means that uploads will be
  enabled.

  If SFTP is not enabled, this parameter will be ignored.

(adding-ssh)=

#### Adding an SSH connection

If you are using the default authentication built into Guacamole, and
you wish to grant access to a SSH connection to a particular user, you
need to locate the `<authorize>` section for that user within your
`user-mapping.xml`, and add a section like the following within it:

```xml
<connection name="Unique Name">
    <protocol>ssh</protocol>
    <param name="hostname">localhost</param>
    <param name="port">22</param>
</connection>
```

If added exactly as above, a new connection named "`Unique Name`" will be
available to the user associated with the `<authorize>` section containing it.
The connection will use SSH to connect to localhost at port 22. Naturally, you
will want to change some or all of these values.

If you want to login automatically rather than receive a login prompt upon
connecting, you can specify a username and password with additional `<param>`
tags. Other options are available for controlling the font.

Other authentication methods will provide documentation describing how to
configure new connections.

### Telnet

Telnet is a text protocol and provides similar functionality to SSH. By nature,
it is not encrypted, and does not provide support for file transfer. As far as
graphics are concerned, Guacamole's telnet support works in the same manner as
SSH: it emulates a terminal on the server side which renders to the Guacamole
client's display.

Telnet support for Guacamole is provided by the libguac-client-telnet library,
which will be installed as part of guacamole-server if the required
dependencies are present during the build.

:::{note}
In addition to the telnet-specific parameters below, Guacamole's telnet support
also accepts the parameters of several features that Guacamole provides for
multiple protocols:

* [](disable-clipboard)
* [](graphical-recording)
* [](typescripts)
* [](stdin-pipe)
* [](terminal-behavior)
* [](terminal-display-settings)
* [](wake-on-lan)
:::

(telnet-network-parameters)=

#### Network parameters

Telnet connections require a hostname or IP address defining the
destination machine. Telnet is standardized to use port 23 and this will
be the proper value in most cases. You only need to specify the telnet
port if you are not using the standard port.

`hostname`
: The hostname or IP address of the telnet server Guacamole should connect
  to.

`port`
: The port the telnet server is listening on, usually 23. This parameter is
  optional. If this is not specified, the default of 23 will be used.

(telnet-authentication)=

#### Authentication

Telnet does not actually provide any standard means of authentication.
Authentication over telnet depends entirely on the login process running on the
server and is interactive. To cope with this, Guacamole provides non-standard
mechanisms for automatically passing the username and entering password.
Whether these mechanisms work depends on specific login process used by your
telnet server.

The de-facto method for passing the username automatically via telnet is to
submit it via the `USER` environment variable, sent using the NEW-ENVIRON
option. This is the mechanism used by most telnet clients, typically via the
`-l` command-line option.

Passwords cannot typically be sent automatically - at least not as reliably as
the username. There is no `PASSWORD` environment variable (this would actually
be a horrible idea) nor any similar mechanism for passing the password to the
telnet login process, and most telnet clients provide no built-in support for
automatically entering the password. The best that can be done is to
heuristically detect the password prompt, and type the password on behalf of
the user when the prompt appears. The prescribed method for doing this with a
traditional command-line telnet is to use a utility like `expect`. Guacamole
provides similar functionality by searching for the password prompt with a
regular expression.

If Guacamole receives a line of text which matches the regular expression, the
password is automatically sent. If no such line is ever received, the password
is not sent, and the user must type the password manually. Pressing any key
during this process cancels the heuristic password prompt detection.

If the password prompt is not being detected properly, you can try using your
own regular expression by specifying it within the `password-regex` parameter.
The regular expression must be written in the POSIX ERE dialect (the dialect
typically used by `egrep`).

`username`
: The username to use to authenticate, if any. This parameter is optional.
  If not specified, or not supported by the telnet server, the login process
  on the telnet server will prompt you for your credentials. For this to
  work, your telnet server must support the NEW-ENVIRON option, and the
  telnet login process must pay attention to the `USER` environment
  variable. Most telnet servers satisfy this criteria.

`password`
: The password to use when attempting authentication, if any. This parameter
  is optional. If specified, your password will be typed on your behalf when
  the password prompt is detected.

`username-regex`
: The regular expression to use when waiting for the username prompt. This
  parameter is optional. If not specified, a reasonable default built into
  Guacamole will be used. The regular expression must be written in the
  POSIX ERE dialect (the dialect typically used by `egrep`).

`password-regex`
: The regular expression to use when waiting for the password prompt. This
  parameter is optional. If not specified, a reasonable default built into
  Guacamole will be used. The regular expression must be written in the
  POSIX ERE dialect (the dialect typically used by `egrep`).

`login-success-regex`
: The regular expression to use when detecting that the login attempt has
  succeeded. This parameter is optional. If specified, the terminal display
  will not be shown to the user until text matching this regular expression
  has been received from the telnet server. The regular expression must be
  written in the POSIX ERE dialect (the dialect typically used by `egrep`).

`login-failure-regex`
: The regular expression to use when detecting that the login attempt has
  failed. This parameter is optional. If specified, the connection will be
  closed with an explicit login failure error if text matching this regular
  expression has been received from the telnet server. The regular
  expression must be written in the POSIX ERE dialect (the dialect typically
  used by `egrep`).

(adding-telnet)=

#### Adding a telnet connection

If you are using the default authentication built into Guacamole, and you wish
to grant access to a telnet connection to a particular user, you need to locate
the `<authorize>` section for that user within your `user-mapping.xml`, and add
a section like the following within it:

```xml
<connection name="Unique Name">
    <protocol>telnet</protocol>
    <param name="hostname">localhost</param>
    <param name="port">23</param>
</connection>
```

If added exactly as above, a new connection named "`Unique Name`" will be
available to the user associated with the `<authorize>` section containing it.
The connection will use telnet to connect to localhost at port 23. Naturally,
you will want to change some or all of these values.

As telnet is inherently insecure compared to SSH, you should use SSH instead
wherever possible. If Guacamole is set up to use HTTPS then communication with
the Guacamole *client* will be encrypted, but communication between guacd and
the telnet server will still be unencrypted. You should not use telnet unless
the network between guacd and the telnet server is trusted.

### Kubernetes

Kubernetes provides an API for attaching to the console of a container over the
network. As with SSH and telnet, Guacamole's Kubernetes support emulates a
terminal on the server side which renders to the Guacamole client's display.

Kubernetes support for Guacamole is provided by the libguac-client-kubernetes
library, which will be installed as part of guacamole-server if the required
dependencies are present during the build.

:::{note}
In addition to the Kubernetes-specific parameters below, Guacamole's Kubernetes
support also accepts the parameters of several features that Guacamole provides
for multiple protocols:

* [](disable-clipboard)
* [](graphical-recording)
* [](typescripts)
* [](stdin-pipe)
* [](terminal-behavior)
* [](terminal-display-settings)
* [](wake-on-lan)
:::


(kubernetes-network-parameters)=

#### Network/Container parameters

Attaching to a Kubernetes container requires the hostname or IP address of the
Kubernetes server and the name of the pod containing the container in question.
By default, Guacamole will attach to the first container in the pod. If there
are multiple containers in the pod, you may wish to also specify the container
name.

`hostname`
: The hostname or IP address of the Kubernetes server
  that Guacamole should connect to.

`port`
: The port the Kubernetes server is listening on for
  API connections. *This parameter is optional.* If
  omitted, port 8080 will be used by default.

`namespace`
: The name of the Kubernetes namespace of the pod containing the container
  being attached to. *This parameter is optional.* If omitted, the namespace
  "default" will be used.

`pod`
: The name of the Kubernetes pod containing with the container being
  attached to.

`container`
: The name of the container to attach to. *This parameter is optional.* If
  omitted, the first container in the pod will be used.

`exec-command`
: The command to run within the container, with input and output attached to
  this command's process. *This parameter is optional.* If omitted, no
  command will be run, and input/output will instead be attached to the main
  process of the container.

  When this parameter is specified, the behavior of the connection is
  analogous to running {command}`kubectl exec`. When omitted, the behavior
  is analogous to running {command}`kubectl attach`.

(kubernetes-authentication)=

#### Authentication and SSL/TLS

If enabled, Kubernetes uses SSL/TLS for both encryption and authentication.
Standard SSL/TLS client authentication requires both a client certificate and
client key, which Guacamole will use to identify itself to the Kubernetes
server. If the certificate used by Kubernetes is self-signed or signed by a
non-standard certificate authority, the certificate for the certificate
authority will also be needed.

`use-ssl`
: If set to "true", SSL/TLS will be used to connect to the Kubernetes
  server. *This parameter is optional.* By default, SSL/TLS will not be
  used.

`client-cert`
: The certificate to use if performing SSL/TLS client authentication to
  authenticate with the Kubernetes server, in PEM format. *This parameter is
  optional.* If omitted, SSL client authentication will not be performed.

`client-key`
: The key to use if performing SSL/TLS client authentication to authenticate
  with the Kubernetes server, in PEM format. *This parameter is optional.*
  If omitted, SSL client authentication will not be performed.

`ca-cert`
: The certificate of the certificate authority that signed the certificate
  of the Kubernetes server, in PEM format. *This parameter is optional.* If
  omitted, verification of the Kubernetes server certificate will use only
  system-wide certificate authorities.

`ignore-cert`
: If set to "true", the validity of the SSL/TLS certificate used by the
  Kubernetes server will be ignored if it cannot be validated. *This
  parameter is optional.* By default, SSL/TLS certificates are validated.

(adding-kubernetes)=

#### Adding a Kubernetes connection

If you are using the default authentication built into Guacamole, and you wish
to grant access to a Kubernetes connection to a particular user, you need to
locate the `<authorize>` section for that user within your `user-mapping.xml`,
and add a section like the following within it:

```xml
<connection name="Unique Name">
    <protocol>kubernetes</protocol>
    <param name="hostname">localhost</param>
    <param name="pod">mypod</param>
</connection>
```

If added exactly as above, a new connection named "`Unique Name`" will be
available to the user associated with the `<authorize>` section containing it.
The connection will connect to the Kubernetes server running on localhost and
attach to the first container of the pod "mypod".

### Common configuration options

(disable-clipboard)=

#### Disabling clipboard access

Guacamole provides bidirectional access to the clipboard by default for all
supported protocols. For protocols that don't inherently provide a clipboard,
Guacamole implements its own clipboard. This behavior can be overridden on a
per-connection basis with the `disable-copy` and `disable-paste` parameters.

`disable-copy`
: If set to "true", text copied within the remote desktop session will not
  be accessible by the user at the browser side of the Guacamole session,
  and will be usable only within the remote desktop. This parameter is
  optional. By default, the user will be given access to the copied text.

`disable-paste`
: If set to "true", text copied at the browser side of the Guacamole session
  will not be accessible within the remote ddesktop session. This parameter
  is optional. By default, the user will be able to paste data from outside
  the browser within the remote desktop session.

(common-sftp)=

#### File transfer via SFTP

Guacamole can provide file transfer over SFTP even when the remote desktop is
otherwise being accessed through a different protocol, like VNC or RDP. If SFTP
is enabled on a Guacamole RDP connection, users will be able to upload and
download files as described in [](using-guacamole).

This support is independent of the file transfer that may be provided by the
protocol in use, like RDP's own "drive redirection" (RDPDR), and is
particularly useful for remote desktop servers which do not support file
transfer features.

`enable-sftp`
: Whether file transfer should be enabled. If set to "true", the user will
  be allowed to upload or download files from the specified server using
  SFTP. If omitted, SFTP will be disabled.

`sftp-hostname`
: The hostname or IP address of the server hosting SFTP. This parameter is
  optional. If omitted, the hostname of the remote desktop server associated
  with the connection will be used.

`sftp-port`
: The port the SSH server providing SFTP is listening on, usually 22. This
  parameter is optional. If omitted, the standard port of 22 will be used.

`sftp-host-key`
: The known hosts entry for the SFTP server. This parameter is optional,
  and, if not provided, no verification of SFTP host identity will be done.
  If the parameter is provided the identity of the server will be checked
  against the data.

  The format of this parameter is that of a single entry from an OpenSSH
  `known_hosts` file.

  For more information, please see [](ssh-host-verification).

`sftp-username`
: The username to authenticate as when connecting to the specified SSH
  server for SFTP. This parameter is optional if a username is specified for
  the remote desktop connection. If omitted, the username specified for the
  remote desktop connection will be used.

`sftp-password`
: The password to use when authenticating with the specified SSH server for
  SFTP.

`sftp-private-key`
: The entire contents of the private key to use for public key
  authentication. If this parameter is not specified, public key
  authentication will not be used. The private key must be in OpenSSH
  format, as would be generated by the OpenSSH {command}`ssh-keygen`
  utility.

`sftp-passphrase`
: The passphrase to use to decrypt the private key for use in public key
  authentication. This parameter is not needed if the private key does not
  require a passphrase.

`sftp-directory`
: The directory to upload files to if they are simply dragged and dropped,
  and thus otherwise lack a specific upload location. This parameter is
  optional. If omitted, the default upload location of the SSH server
  providing SFTP will be used.

`sftp-root-directory`
: The directory to expose to connected users via Guacamole's
  [](file-browser). If omitted, the root directory will be used by default.

`sftp-server-alive-interval`
: The interval in seconds at which to send keepalive packets to the SSH
  server for the SFTP connection. This parameter is optional. If omitted,
  the default of 0 will be used, disabling sending keepalive packets. The
  minimum value is 2.

`sftp-disable-download`
: If set to true downloads from the remote system to the client (browser)
  will be disabled. The default is false, which means that downloads will be
  enabled.

  If sftp is not enabled, this parameter will be ignored.

`sftp-disable-upload`
: If set to true uploads from the client (browser) to the remote system will
  be disabled. The default is false, which means that uploads will be
  enabled.

  If sftp is not enabled, this parameter will be ignored.

(graphical-recording)=

#### Graphical session recording

Sessions of all supported protocols can be recorded graphically. These
recordings take the form of Guacamole protocol dumps and are recorded
automatically to a specified directory. Recordings can be subsequently
translated to a normal video stream using the {program}`guacenc` utility
provided with guacamole-server.

For example, to produce a video called {samp}`{NAME}.m4v` from the recording
"`NAME`", you would run:

```console
$ guacenc /path/to/recording/NAME
```

The {program}`guacenc` utility has additional options for overriding default
behavior, including tweaking the output format, which are documented in detail
within the manpage:

```console
$ man guacenc
```

If recording of key events is explicitly enabled using the
`recording-include-keys` parameter, recordings can also be translated into
human-readable interpretations of the keys pressed during the session using the
{program}`guaclog` utility. The usage of {program}`guaclog` is analogous to
{program}`guacenc`, and results in the creation of a new text file containing
the interpreted events:

```console
$ guaclog /path/to/recording/NAME
guaclog: INFO: Guacamole input log interpreter (guaclog) version 1.4.0
guaclog: INFO: 1 input file(s) provided.
guaclog: INFO: Writing input events from "/path/to/recording/NAME" to "/path/to/recording/NAME.txt" ...
guaclog: INFO: All files interpreted successfully.
$
```

:::{important}
Guacamole will never overwrite an existing recording. If necessary, a numeric
suffix like ".1", ".2", ".3", etc. will be appended to <NAME> to avoid
overwriting an existing recording. If even appending a numeric suffix does not
help, the session will simply not be recorded.
:::

`recording-path`
: The directory in which screen recording files should be created. *If a
  graphical recording needs to be created, then this parameter is required.*
  Specifying this parameter enables graphical screen recording. If this
  parameter is omitted, no graphical recording will be created.

`create-recording-path`
: If set to "true", the directory specified by the `recording-path`
  parameter will automatically be created if it does not yet exist. Only the
  final directory in the path will be created - if other directories earlier
  in the path do not exist, automatic creation will fail, and an error will
  be logged.

  *This parameter is optional.* By default, the directory specified by the
  `recording-path` parameter will not automatically be created, and attempts
  to create recordings within a non-existent directory will be logged as
  errors.

  This parameter only has an effect if graphical recording is enabled. If
  the `recording-path` is not specified, graphical session recording will be
  disabled, and this parameter will be ignored.

`recording-name`
: The filename to use for any created recordings. *This parameter is
  optional.* If omitted, the value "recording" will be used instead.

  This parameter only has an effect if graphical recording is enabled. If
  the `recording-path` is not specified, graphical session recording will be
  disabled, and this parameter will be ignored.

`recording-exclude-output`
: If set to "true", graphical output and other data normally streamed from
  server to client will be excluded from the recording, producing a
  recording which contains only user input events. *This parameter is
  optional.* If omitted, graphical output will be included in the recording.

  This parameter only has an effect if graphical recording is enabled. If
  the `recording-path` is not specified, graphical session recording will be
  disabled, and this parameter will be ignored.

`recording-exclude-mouse`
: If set to "true", user mouse events will be excluded from the recording,
  producing a recording which lacks a visible mouse cursor. *This parameter
  is optional.* If omitted, mouse events will be included in the recording.

  This parameter only has an effect if graphical recording is enabled. If
  the `recording-path` is not specified, graphical session recording will be
  disabled, and this parameter will be ignored.

`recording-include-keys`
: If set to "true", user key events will be included in the recording. The
  recording can subsequently be passed through the {program}`guaclog` utility
  to produce a human-readable interpretation of the keys pressed during the
  session. *This parameter is optional.* If omitted, key events will be not
  included in the recording.

  This parameter only has an effect if graphical recording is enabled. If
  the `recording-path` is not specified, graphical session recording will be
  disabled, and this parameter will be ignored.

(typescripts)=

#### Text session recording (typescripts)

The full, raw text content of SSH sessions, including timing information, can
be recorded automatically to a specified directory. This recording, also known
as a "typescript", will be written to two files within the directory specified
by `typescript-path`: {samp}`{NAME}`, which contains the raw text data, and
{samp}`{NAME}.timing`, which contains timing information, where `NAME` is the
value provided for the `typescript-name` parameter.

This format is compatible with the format used by the standard UNIX
{command}`script` command, and can be replayed using {command}`scriptreplay`
(if installed). For example, to replay a typescript called "`NAME`", you would
run:

```console
$ scriptreplay NAME.timing NAME
```

:::{important}
Guacamole will never overwrite an existing recording. If necessary, a numeric
suffix like ".1", ".2", ".3", etc. will be appended to `NAME` to avoid
overwriting an existing recording. If even appending a numeric suffix does not
help, the session will simply not be recorded.
:::

`typescript-path`
: The directory in which typescript files should be created. *If a
  typescript needs to be recorded, this parameter is required.* Specifying
  this parameter enables typescript recording. If this parameter is omitted,
  no typescript will be recorded.

`create-typescript-path`
: If set to "true", the directory specified by the `typescript-path`
  parameter will automatically be created if it does not yet exist. Only the
  final directory in the path will be created - if other directories earlier
  in the path do not exist, automatic creation will fail, and an error will
  be logged.

  *This parameter is optional.* By default, the directory specified by the
  `typescript-path` parameter will not automatically be created, and
  attempts to record typescripts in a non-existent directory will be logged
  as errors.

  This parameter only has an effect if typescript recording is enabled. If
  the `typescript-path` is not specified, recording of typescripts will be
  disabled, and this parameter will be ignored.

`typescript-name`
: The base filename to use when determining the names for the data and
  timing files of the typescript. *This parameter is optional.* If omitted,
  the value "typescript" will be used instead.

  Each typescript consists of two files which are created within the
  directory specified by `typescript-path`: {samp}`{NAME}`, which contains
  the raw text data, and {samp}`{NAME}.timing`, which contains timing
  information, where `NAME` is the value provided for the `typescript-name`
  parameter.

  This parameter only has an effect if typescript recording is enabled. If
  the `typescript-path` is not specified, recording of typescripts will be
  disabled, and this parameter will be ignored.

(terminal-behavior)=

#### Controlling terminal behavior

In most cases, the default behavior for a terminal works without modification.
However, when connecting to certain systems, particularly operating systems
other than Linux, the terminal behavior may need to be tweaked to allow it to
operate properly. The settings in this section control that behavior.

`backspace`
: This parameter controls the ASCII code that the backspace key sends to the
  remote system. Under most circumstances this should not need to be
  adjusted; however, if, when pressing the backspace key, you see control
  characters (often either ^? or ^H) instead of seeing the text erased, you
  may need to adjust this parameter. By default the terminal sends ASCII
  code 127 (Delete) if this option is not set.

`terminal-type`
: This parameter sets the terminal emulator type string that is passed to
  the server. This parameter is optional. If not specified, "`linux`" is used
  as the terminal emulator type by default.

(stdin-pipe)=

##### Providing terminal input directly from JavaScript

If Guacamole is being used in part to automate an SSH, telnet, or other
terminal session, it can be useful to provide input directly from JavaScript as
a raw stream of data, rather than attempting to translate data into keystrokes.
This can be done through opening a pipe stream named "STDIN" within the
connection using the [`createPipeStream()`](http://guacamole.apache.org/doc/guacamole-common-js/Guacamole.Client.html#createPipeStream)
function of [`Guacamole.Client`](http://guacamole.apache.org/doc/guacamole-common-js/Guacamole.Client.html):

```javascript
var outputStream = client.createPipeStream('text/plain', 'STDIN');
```

The resulting [`Guacamole.OutputStream`](http://guacamole.apache.org/doc/guacamole-common-js/Guacamole.OutputStream.html)
can then be used to stream data directly to the input of the terminal session,
as if typed by the user:

```javascript
// Wrap output stream in writer
var writer = new Guacamole.StringWriter(outputStream);

// Send text
writer.sendText("hello");

// Send more text
writer.sendText("world");

// Close writer and stream
writer.sendEnd();
```

(terminal-display-settings)=

#### Terminal display settings

Guacamole's terminal emulator (used by SSH, telnet, and Kubernetes support)
provides options for configuring the font used and its size. In this case, *the
chosen font must be installed on the server*, as it is the server that will
handle rendering of characters to the terminal display, not the client.

`color-scheme`
: The color scheme to use for the terminal session. It consists of a
  semicolon-separated series of name-value pairs. Each name-value pair is
  separated by a colon and assigns a value to a color in the terminal
  emulator palette. For example, to use blue text on white background by
  default, and change the red color to a purple shade, you would specify:

  ```
  foreground: rgb:00/00/ff;
  background: rgb:ff/ff/ff;
  color9: rgb:80/00/80
  ```

  This format is similar to the color configuration format used by Xterm, so
  Xterm color configurations can be easily adapted for Guacamole. This
  parameter is optional. If not specified, Guacamole will render text as
  gray over a black background.

  Possible color names are:

  `foreground`
  : Set the default foreground color.

  `background`
  : Set the default background color.

  {samp}`color{N}`
  : Set the color at index `N` on the Xterm 256-color palette. For example,
    `color9` refers to the red color.

  Possible color values are:

  {samp}`rgb:{RR}/{GG}/{BB}`
  : Use the specified color in RGB format, with each component in
    hexadecimal. For example, `rgb:ff/00/00` specifies the color red. Note
    that each hexadecimal component can be one to four digits, but the
    effective values are always zero-extended or truncated to two digits;
    for example, `rgb:f/8/0`, `rgb:f0/80/00`, and `rgb:f0f/808/00f` all
    refer to the same effective color.

  {samp}`color{N}`
  : Use the color currently assigned to index `N` on the Xterm 256-color
    palette. For example, `color9` specifies the current red color. Note
    that the color value is used rather than the color reference, so if
    `color9` is changed later in the color scheme configuration, that new
    color will not be reflected in this assignment.

  For backward compatibility, Guacamole will also accept four special values as
  the color scheme parameter:

  `black-white`
  : Black text over a white background.

  `gray-black`
  : Gray text over a black background. This is the default color scheme.

  `green-black`
  : Green text over a black background.

  `white-black`
  : White text over a black background.

`font-name`
: The name of the font to use. This parameter is optional. If not specified,
  the default of "monospace" will be used instead.

`font-size`
: The size of the font to use, in points. This parameter is optional. If not
  specified, the default of 12 will be used instead.

`scrollback`
: The maximum number of rows to allow within the terminal scrollback buffer.
  This parameter is optional. If not specified, the scrollback buffer will
  be limited to a maximum of 1000 rows.

(wake-on-lan)=

#### Wake-on-LAN

Guacamole implements the support to send a "magic wake-on-lan packet" to a
remote host prior to attempting to establish a connection with the host. The
below parameters control the behavior of this functionality, which is disabled
by default.

:::{important}
There are several factors that can impact the ability of Wake-on-LAN (WoL) to
function correctly, many of which are outside the scope of Guacamole
configuration. If you are configuring WoL within Guacamole you should also be
familiar with the other components that need to be configured in order for it
to function correctly.
:::

`wol-send-packet`
: If set to "true", Guacamole will attempt to send the Wake-On-LAN packet
  prior to establishing a connection. This parameter is optional. By
  default, Guacamole will not send the WoL packet. Enabling this option
  requires that the `wol-mac-addr` parameter also be configured, otherwise
  the WoL packet will not be sent.

`wol-mac-addr`
: This parameter configures the MAC address that Guacamole will use in the
  magic WoL packet to attempt to wake the remote system. If
  `wol-send-packet` is enabled, this parameter is required or else the WoL
  packet will not be sent.

`wol-broadcast-addr`
: This parameter configures the IPv4 broadcast address or IPv6 multicast
  address that Guacamole will send the WoL packet to in order to wake the
  host. This parameter is optional. If no value is provided, the default
  local IPv4 broadcast address (255.255.255.255) will be used.

`wol-udp-port`
: This parameter configures the UDP port that will be set in the WoL packet.
  In most cases the UDP port isn't processed by the system that will be
  woken up; however, there are certain cases where it is useful for the port
  to be set, as in situations where a router is listening for the packet and
  can make routing decisions depending upon the port that is used. If not
  configured the default UDP port 9 will be used.

`wol-wait-time`
: By default after the WoL packet is sent Guacamole will attempt immediately
  to connect to the remote host. It may be desirable in certain scenarios to
  have Guacamole wait before the initial connection in order to give the
  remote system time to boot. Setting this parameter to a positive value
  will cause Guacamole to wait the specified number of seconds before
  attempting the initial connection. This parameter is optional.

(parameter-tokens)=

### Parameter tokens

The values of connection parameters can contain "tokens" which will be replaced
by Guacamole when used. These tokens allow the values of connection parameters
to vary dynamically by the user using the connection, and provide a simple
means of forwarding authentication information without storing that information
in the connection configuration itself, so long as the remote desktop
connection uses the same credentials as Guacamole.

Each token is of the form {samp}`$\{{TOKEN_NAME}\}` or
{samp}`$\{{TOKEN_NAME}:{MODIFIER}\}`, where `TOKEN_NAME` is some descriptive
name for the value the token represents, and the optional `MODIFIER` is one of
the modifiers documented below to dynamically modify the token.  Tokens with no
corresponding value will never be replaced, but should you need such text
within your connection parameters, and wish to guarantee that this text will
not be replaced with a token value, you can escape the token by adding an
additional leading "$", as in "{samp}`$$\{{TOKEN_NAME}\}`".

`${GUAC_USERNAME}`
: The username of the current Guacamole user. When a user accesses a
  connection, this token will be dynamically replaced with the username they
  provided when logging in to Guacamole.

`${GUAC_PASSWORD}`
: The password of the current Guacamole user. When a user accesses a
  connection, this token will be dynamically replaced with the password they
  used when logging in to Guacamole.

`${GUAC_CLIENT_ADDRESS}`
: The IPv4 or IPv6 address of the current Guacamole user. This will be the
  address of the client side of the HTTP connection to the Guacamole server
  at the time the current user logged in.

`${GUAC_CLIENT_HOSTNAME}`
: The hostname of the current Guacamole user. This will be the hostname of
  the client side of the HTTP connection to the Guacamole server at the time
  the current user logged in. If no such hostname can be determined, the
  IPv4 or IPv6 address will be used instead, and this token will be
  equivalent to `${GUAC_CLIENT_ADDRESS}`.

`${GUAC_DATE}`
: The current date in the local time zone of the Guacamole server. This will
  be written in "YYYYMMDD" format, where "YYYY" is the year, "MM" is the
  month number, and "DD" is the day of the month, all zero-padded. When a
  user accesses a connection, this token will be dynamically replaced with
  the date that the connection began.

`${GUAC_TIME}`
: The current time in the local time zone of the Guacamole server. This will
  be written in "HHMMSS" format, where "HH" is hours in 24-hour time, "MM"
  is minutes, and "SS" is seconds, all zero-padded. When a user accesses a
  connection, this token will be dynamically replaced with the time that the
  connection began.

Note that these tokens are replaced dynamically each time a connection is used.
If two different users access the same connection at the same time, both users
will be connected independently of each other using different sets of
connection parameters.

#### Token modifiers

At times it can be useful to use the value provided by a token, but with slight
modifications. These modifers are optionally specified at the end of the token,
separated from the token name by a colon (`:`), in the format
{samp}`$\{{TOKEN_NAME}:{MODIFIER}\}`. The following modifiers are currently
supported:

`LOWER`
: Convert the entire value of the token to lower-case. This can be useful in
  situations where users log in to Guacamole with a mixed-case username, but
  a remote system requires the username be lower-case.

`UPPER`
: Convert the entire value of the token to upper-case.

(extension-tokens)=

#### Extension-specific tokens

Each extension can also implement its own arbitrary tokens that can
dynamically fill in values provided by the extension. Within these
extensions, attribute names are canonicalized into a standard format
that consists of all capital letters separated by underscores.

(cas-tokens)=

##### CAS Extension Tokens

The CAS extension will read attributes provided by the CAS server when a user
is authenticated and will make those attributes available as tokens. The CAS
server must be specifically configured to release certain attributes to the
client (Guacamole), and configuration of that is outside the scope of this
document. Any attribute that the CAS server is configured to release should be
available to Guacamole as a token for use within a connection. The token name
will be prepended with the `CAS_` prefix. A CAS server configured to release
attributes `firstname`, `lastname`, `email`, and `mobile` would produce the
following tokens:

* `${CAS_FIRSTNAME}`
* `${CAS_LASTNAME}`
* `${CAS_EMAIL}`
* `${CAS_MOBILE}`

(ldap-tokens)=

##### LDAP Extension Tokens

The LDAP extension will read user attributes provided by the LDAP server and
specified in the `guacamole.properties` file. The attributes retrieved for a
user are configured using the `ldap-user-attributes` parameter. The user must
be able to read the attribute values from their own LDAP object. The token name
will be prepended with the `LDAP_` prefix. As an example, configuring the
following line in `guacamole.properties`:

```
ldap-user-attributes: cn, givenName, sn, mobile, mail
```

will produce the below tokens that can be used in connection parameters:

* `${LDAP_CN}`
* `${LDAP_GIVENNAME}`
* `${LDAP_SN}`
* `${LDAP_MOBILE}`
* `${LDAP_MAIL}`

### Parameter prompting

In certain situations Guacamole may determine that additional information is
required in order to successfully open or continue a connection. In these
scenarios guacd will send an instruction back to the client to retrieve that
information, which will result in the user being prompted for those additional
parameters.

Currently the only parameters that will trigger this prompt to the user are
authentication requests for the RDP and VNC protocols where authenticators were
not provided as part of the connection configuration.

:::{important}
It is important to note that requests for parameters will only be generated in
the case where that information has not already been provided as part of the
connection. **The user will never be asked for parameters that replace or
override connection parameters where values have been provided**, including
authentication information.

For example, if the configuration of a connection to a RDP server specifies a
username and password, and that username or password is incorrect and results
in an authentication failure, Guacamole will not prompt the user for additional
credentials. For RDP servers where NLA is enforced, this will result in a
connection failure. Other RDP servers may behave differently and give the user
the ability to try other credentials, but this is outside the control of
Guacamole - **Guacamole will not override pre-configured authentication values
with input from the user**.
:::

(guacd.conf)=

Configuring guacd
-----------------

### `guacd.conf`

guacd is configured with a configuration file called `guacd.conf`, by
default located in `/etc/guacamole`. This file follows a simple,
INI-like format:

```
#
# guacd configuration file
#

[daemon]

pid_file = /var/run/guacd.pid
log_level = info

[server]

bind_host = localhost
bind_port = 4822

#
# The following parameters are valid only if
# guacd was built with SSL support.
#

[ssl]

server_certificate = /etc/ssl/certs/guacd.crt
server_key = /etc/ssl/private/guacd.key
```

Configuration options are given as parameter/value pairs, where the name of the
parameter is specified on the left side of an "`=`", and the value is specified
on the right. Each parameter must occur within a proper section, indicated by a
section name within brackets. The names of these sections are important; it is
the pairing of a section name with a parameter that constitutes the
fully-qualified parameter being set.

For the sake of documentation and readability, comments can be added anywhere
within guacd.conf using "`#`" symbols. All text following a "`#`" until
end-of-line will be ignored.

If you need to include special characters within the value of a parameter, such
as whitespace or any of the above symbols, you can do so by placing the
parameter within double quotes:

```
[ssl]

# Whitespace is legal within double quotes ...
server_certificate = "/etc/ssl/my certs/guacd.crt"

# ... as are other special symbols
server_key = "/etc/ssl/#private/guacd.key"
```

Note that even within double quotes, some characters still have special
meaning, such as the double quote itself or newline characters. If you need to
include these, they must be "escaped" with a backslash:

```
# Parameter value containing a double quote
parameter = "some\"value"

# Parameter value containing newline characters
parameter2 = "line1\
line2\
line3"

# Parameter value containing backslashes
parameter3 = "c:\\windows\\path\\to\\file.txt"
```

Don't worry too much about the more complex formatting examples - they are only
rarely necessary, and guacd will complain with parsing errors if the
configuration file is somehow invalid. To ensure parameter values are entered
correctly, just follow the following guidelines:

1. If the value contains no special characters, just include it as-is.

2. If the value contains any special characters (whitespace, newlines, `#`,
   `\`, or `"`), enclose the entire value within double quotes.

3. If the value is enclosed within double quotes, escape newlines, `\`, and `"`
   with a backslash.

(guacd-conf-daemon)=

#### `[daemon]` section

`pid_file`
: The name of the file in which the PID of the main guacd process should be
  written. This is mainly needed for startup scripts, which need to monitor
  the state of guacd, killing it if necessary. If this parameter is
  specified, the user running guacd must have sufficient permissions to
  create or modify the specified file, or startup will fail.

`log_level`
: The maximum level at which guacd will log messages to syslog and, if
  running in the foreground, the console. If omitted, the default level of
  `info` will be used.

  Legal values are `trace`, `debug`, `info`, `warning`, and `error`.

(guacd-conf-server)=

#### `[server]` section

`bind_host`
: The host that guacd should bind to when listening for connections. If
  unspecified, guacd will bind to localhost, and only connections from
  within the server hosting guacd will succeed.

`bind_port`
: The port that guacd should bind to when listening for connections. If
  unspecified, port 4822 will be used.

(guacd-conf-ssl)=

#### `[ssl]` section

`server_certificate`
: The filename of the certificate to use for SSL encryption of the Guacamole
  protocol. If this option is specified, SSL encryption will be enabled, and
  the Guacamole web application will need to be configured within
  `guacamole.properties` to use SSL as well.

`server_key`
: The filename of the private key to use for SSL encryption of the Guacamole
  protocol. If this option is specified, SSL encryption will be enabled, and
  the Guacamole web application will need to be configured within
  `guacamole.properties` to use SSL as well.

### Command-line options

You can also affect the configuration of guacd with command-line
options. If given, these options take precendence over the system-wide
configuration file:

{samp}`-b {HOST}`
: Changes the host or address that guacd listens on.

  This corresponds to the `bind_host` parameter within the [`[server]` section
  of `guacd.conf`](guacd-conf-server).

{samp}`-l {PORT}`
: Changes the port that guacd listens on (the default is port 4822).

  This corresponds to the `bind_port` parameter within the [`[server]` section
  of `guacd.conf`](guacd-conf-server).

{samp}`-p {PIDFILE}`
: Causes guacd to write the PID of the daemon process to the specified file.
  This is useful for init scripts and is used by the provided init script.

  This corresponds to the `pid_file` parameter within the [`[daemon]` section
  of `guacd.conf`](guacd-conf-daemon).

{samp}`-L {LEVEL}`
: Sets the maximum level at which guacd will log messages to syslog and, if
  running in the foreground, the console. Legal values are `trace`, `debug`,
  `info`, `warning`, and `error`. The default value is `info`.

  This corresponds to the `log_level` parameter within the [`[daemon]` section
  of `guacd.conf`](guacd-conf-daemon).

`-f`
: Causes guacd to run in the foreground, rather than automatically forking
  into the background.

If guacd was built with support for SSL, data sent via the Guacamole protocol
can be encrypted with SSL if an SSL certificate and private key are given with
the following options:

{samp}`-C {CERTIFICATE}`
: The filename of the certificate to use for SSL encryption of the Guacamole
  protocol. If this option is specified, SSL encryption will be enabled, and
  the Guacamole web application will need to be configured within
  `guacamole.properties` to use SSL as well.

  This corresponds to the `server_certificate` parameter within the [`[ssl]`
  section of `guacd.conf`](guacd-conf-ssl).

{samp}`-K {KEY}`
: The filename of the private key to use for SSL encryption of the Guacamole
  protocol. If this option is specified, SSL encryption will be enabled, and
  the Guacamole web application will need to be configured within
  `guacamole.properties` to use SSL as well.

  This corresponds to the `server_key` parameter within the [`[ssl]` section of
  `guacd.conf`](guacd-conf-ssl).

