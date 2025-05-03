Installing Guacamole with Docker
================================

Guacamole can be deployed using Docker, removing the need to build
guacamole-server from source or configure the web application manually.  The
Guacamole project provides officially-supported Docker images for both
Guacamole and guacd which are kept up-to-date with each release.

A typical Docker deployment of Guacamole will involve three separate
containers, connected over the network:

`guacamole/guacd`
: Provides the guacd daemon, built from the released guacamole-server source
  with support for VNC, RDP, SSH, telnet, and Kubernetes.

`guacamole/guacamole`
: Provides the Guacamole web application running within Tomcat 9.x with support
  for WebSocket. The configuration necessary to connect to guacd, MySQL,
  PostgreSQL, LDAP, etc. will be read automatically from environment variables
  when the image starts.

`mysql` or `postgresql`
: Provides the database that Guacamole will use for authentication and storage
  of connection configuration data.

This separation is important, as it facilitates upgrades and maintains proper
separation of concerns. With the database separate from Guacamole and guacd,
those containers can be freely destroyed and recreated at will. The only
container which must persist data through upgrades is the database.

(guacd-docker-image)=

Running the guacd Docker image
------------------------------

The guacd Docker image is built from the released guacamole-server source with
support for VNC, RDP, SSH, telnet, and Kubernetes. Common pitfalls like
installing the required dependencies, installing fonts for SSH, telnet, or
Kubernetes, and ensuring the FreeRDP plugins are installed to the correct
location are all taken care of. It will simply just work.

(guacd-docker-guacamole)=

### Running guacd for use by the Guacamole Docker image

When running the guacd image with the intent of connecting with a Guacamole
container, no ports need be exposed on the network. Access to these ports will
be handled automatically by Docker through the use of an isolated network:

```console
$ docker run --network=some-network --name some-guacd -d guacamole/guacd
```

When run in this manner, guacd will be listening on its default port 4822, but
this port will only be available via the dedicated Docker network,
`some-network`.

The log level of guacd can be controlled with the `LOG_LEVEL` environment
variable. The default value is `info`, and can be set to any of the valid
settings for the guacd log flag (`-L`).

```console
$ docker run --network=some-network --name some-guacd \
    -e LOG_LEVEL=debug -d guacamole/guacd
```

(guacd-docker-external)=

### Running guacd for use by services outside Docker

If you are not going to use the Guacamole image, you can still leverage the
guacd image for ease of installation and maintenance. By exposing the guacd
port, 4822, services external to Docker will be able to access guacd.

:::{important}
*Take great care when doing this* - guacd is a passive proxy and does not
perform any kind of authentication.

If you do not properly isolate guacd from untrusted parts of your network,
malicious users may be able to use guacd as a jumping point to other systems.
:::

```console
$ docker run --name some-guacd -d -p 4822:4822 guacamole/guacd
```

guacd will now be listening on port 4822, and Docker will expose this port on
the same server hosting Docker. Other services, such as an instance of Tomcat
running outside of Docker, will be able to connect to guacd directly.

(guacamole-docker-image)=

The Guacamole Docker image
--------------------------

The Guacamole Docker image is built on top of a standard Tomcat 9.x image and
takes care of all configuration automatically. The configuration information
required for guacd and the various authentication mechanisms are specified with
environment variables given when the container is created.

:::{important}
If using [PostgreSQL](postgresql-auth) or [MySQL](mysql-auth) for
authentication, *you will need to initialize the database manually*.  Guacamole
will not automatically create its own tables, but SQL scripts are provided to
do this.
:::

Once the Guacamole image is running, Guacamole will be accessible at
{samp}`http://{HOSTNAME}:8080/guacamole/`, where `HOSTNAME` is the hostname or
address of the machine hosting Docker. To set the path Guacamole is accessible from,
use the `WEBAPP_CONTEXT` environment variable:

`WEBAPP_CONTEXT`
: The path Guacamole should be accessible from. If set to `ROOT` Guacamole
will accessible from {samp}`http://{HOSTNAME}:8080`.

(guacamole-docker-config-via-env)=

### Configuring Guacamole when using Docker

When running Guacamole using Docker, the traditional approach to configuring
Guacamole by editing `guacamole.properties` is instead primarily accomplished
using environment variables. For each property that the web application or an
extension might read, the value of that property is read from a corresponding
environment variable.

Each of these environment variables are explicitly documented alongside their
original properties, but they are named consistently by transforming the
property into uppercase and replacing all dashes with underscores.

:::{hint}
This means that even custom, third-party extensions that leverage properties
from `guacamole.properties` are automatically configurable using environment
variables within the `guacamole/guacamole` image.
:::

(guacamole-docker-guacd)=

### Connecting Guacamole to guacd

The Guacamole Docker image needs to be able to connect to guacd to establish
remote desktop connections, just like any other Guacamole deployment, however
the connection information needed by Guacamole will be provided via environment
variables.

If you will be using Docker to provide guacd, and you wish to use a dedicated
network for these services, you can just use the container name as the
hostname:

```console
$ docker run --network=some-network --name some-guacamole \
    -e GUACD_HOSTNAME=some-guacamole -d -p 8080:8080 guacamole/guacamole
```

The network connection information for guacd is provided using additional
environment variables:

`GUACD_HOSTNAME`
: The hostname of the guacd instance to use to establish remote desktop
  connections. *This is required if you are not using Docker to provide guacd.*

`GUACD_PORT`
: The port that Guacamole should use when connecting to guacd. This environment
  variable is optional. If not provided, the standard guacd port of 4822 will
  be used.

*A connection to guacd is not the only thing required for Guacamole to work*;
some authentication mechanism needs to be configured, as well.
[MySQL](mysql-auth), [PostgreSQL](postgresql-auth), and [LDAP](ldap-auth) are
supported for this, and are described in more detail in the sections below. If
the required configuration options for at least one authentication mechanism
are not provided, the Guacamole image will not be able to start up, and you
will see an error.

(guacamole-docker-proxy)=

### Running Guacamole behind a proxy

To run Guacamole behind a reverse proxy, Tomcat's
[`RemoteIpValve`](https://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Remote_IP_Valve)
must be configured as described in [](tomcat-remote-ip) to ensure that the
user's IP address can be correctly determined and logged. The Guacamole Docker
image provides environment variables for configuring this.

(guacamole-docker-tomcat-remote-ip-valve-required-vars)=

#### Required environment variables

The following environment variable must be set in order to configure Tomcat's
[`RemoteIpValve`](https://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Remote_IP_Valve):

`REMOTE_IP_VALVE_ENABLED`
: Set to `true` to enable Tomcat's [`RemoteIpValve`](https://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Remote_IP_Valve).
  **If this is not set, all other variables related to `RemoteIpValve` will be
  ignored.**

(guacamole-docker-tomcat-remote-ip-valve-optional-vars)=

#### Optional environment variables

Additional environment variables are available to fine tune the configuration
of `RemoteIpValve`. **It is not typically necessary to set these variables.**
The default values are correct for most deployments.

`PROXY_ALLOWED_IPS_REGEX`
: A regular expression matching only the IP addresses that should be trusted to
  send proxy headers, corresponding to the `internalProxies` attribute of
  `RemoteIpValve`. Proxy headers from other addresses will be ignored. The
  regular expression must conform to the format accepted by [Java's `Pattern`
  class](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html),
  which is largely compatible with Perl.

  If omitted, Tomcat's default which matches private IPv4 and IPv6 addresses
  will be used.

`PROXY_BY_HEADER`
: The HTTP header sent by the proxy that contains the list of proxies that have
  processed the request. This corresponds to the `proxiesHeader` attribute of
  `RemoteIpValve`. By default, this will be `X-Forwarded-By`.

`PROXY_IP_HEADER`
: The HTTP header sent by the proxy that contains the user's browser's IP
  address. This corresponds to the `remoteIpHeader` attribute of
  `RemoteIpValve`. By default, this will be `X-Forwarded-For`.

`PROXY_PROTOCOL_HEADER`
: The HTTP header sent by the proxy that contains the protocol used by the
  user's browser to connect to the proxy. This corresponds to the
  `protocolHeader` attribute of `RemoteIpValve`. By default, this will be
  `X-Forwarded-Proto`.

(guacamole-docker-guacamole-home)=

### Custom extensions and `GUACAMOLE_HOME`

If you have your own or third-party extensions for Guacamole which are not
supported by the Guacamole Docker image, but are compatible with the version of
Guacamole within the image, you can still use them exactly as you would with a
native Guacamole installation. The Guacamole web application within the image
uses the same standard configuration paths and files.

Additionally, the `guacamole/guacamole` image provides some configuration
mechanisms for convenience:

* Configuration properties that are normally consumed by your extension via
  `guacamole.properties` can instead be specified with corresponding
  environment variables. Within the Docker image, the Guacamole web application
  will automatically read properties from environment variables that are named
  by transforming the property name into uppercase and replacing all dashes
  with underscores.

* The `GUACAMOLE_HOME` environment variable informs the image where to look for
  your configuration and defaults to `/etc/guacamole`. If you need to use a
  different location, you can simply point this variable at that location
  instead.

The image is designed to use any provided `GUACAMOLE_HOME` configuration as a
template while leaving its contents untouched. The web application will be
pointed at a temporary location whose contents have been non-destructively
copied/linked from the files you have provided. **The image does not need write
access to any custom configuration files/directories.**

(verifying-guacamole-docker)=

### Verifying the Guacamole install

Once the Guacamole image is running, Guacamole should be accessible at
{samp}`http://{HOSTNAME}:8080/guacamole/` (or the path you set with
`WEBAPP_CONTEXT`), where `HOSTNAME` is the hostname or address of the machine
hosting Docker, and you *should* see a login screen.

If you cannot access Guacamole, or you do not see a login screen, check
Docker's logs using the `docker logs` command to determine if something is
wrong. Configuration parameters may have been given incorrectly, or the
database may be improperly initialized:

```console
$ docker logs some-guacamole
```

