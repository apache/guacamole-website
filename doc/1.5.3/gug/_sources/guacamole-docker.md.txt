Installing Guacamole with Docker
================================

Guacamole can be deployed using Docker, removing the need to build
guacamole-server from source or configure the web application manually.  The
Guacamole project provides officially-supported Docker images for both
Guacamole and guacd which are kept up-to-date with each release.

A typical Docker deployment of Guacamole will involve three separate
containers, linked together at creation time:

`guacamole/guacd`
: Provides the guacd daemon, built from the released guacamole-server source
  with support for VNC, RDP, SSH, telnet, and Kubernetes.

`guacamole/guacamole`
: Provides the Guacamole web application running within Tomcat 8 with support
  for WebSocket. The configuration necessary to connect to guacd, MySQL,
  PostgreSQL, LDAP, etc. will be generated automatically when the image starts
  based on Docker links or environment variables.

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

When running the guacd image with the intent of linking to a Guacamole
container, no ports need be exposed on the network. Access to these ports will
be handled automatically by Docker during linking, and the Guacamole image will
properly detect and configure the connection to guacd.

```console
$ docker run --name some-guacd -d guacamole/guacd
```
When run in this manner, guacd will be listening on its default port 4822, but
this port will only be available to Docker containers that have been explicitly
linked to `some-guacd`.

The log level of guacd can be controlled with the `GUACD_LOG_LEVEL` environment
variable. The default value is `info`, and can be set to any of the valid
settings for the guacd log flag (-L).

```console
$ docker run -e GUACD_LOG_LEVEL=debug -d guacamole/guacd
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

The Guacamole Docker image is built on top of a standard Tomcat 8 image and
takes care of all configuration automatically. The configuration information
required for guacd and the various authentication mechanisms are specified with
environment variables or Docker links given when the container is created.

:::{important}
If using [PostgreSQL](guacamole-docker-postgresql) or [MySQL](guacamole-docker-mysql)
for authentication, *you will need to initialize the database manually*.
Guacamole will not automatically create its own tables, but SQL scripts are
provided to do this.
:::

Once the Guacamole image is running, Guacamole will be accessible at
{samp}`http://{HOSTNAME}:8080/guacamole/`, where `HOSTNAME` is the hostname or
address of the machine hosting Docker.

(guacamole-docker-config-via-env)=

### Configuring Guacamole when using Docker

When running Guacamole using Docker, the traditional approach to configuring
Guacamole by editing `guacamole.properties` is less convenient. When using
Docker, you may wish to make use of the `enable-environment-properties`
configuration property, which allows you to specify values for arbitrary
Guacamole configuration properties using environment variables. This is covered
in [](configuring-guacamole).

(guacamole-docker-guacd)=

### Connecting Guacamole to guacd

The Guacamole Docker image needs to be able to connect to guacd to establish
remote desktop connections, just like any other Guacamole deployment. The
connection information needed by Guacamole will be provided either via a Docker
link or through environment variables.

If you will be using Docker to provide guacd, and you wish to use a Docker link
to connect the Guacamole image to guacd, the connection details are implied by
the Docker link:

```console
$ docker run --name some-guacamole \
    --link some-guacd:guacd        \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

If you are not using Docker to provide guacd, you will need to provide the
network connection information yourself using additional environment variables:

`GUACD_HOSTNAME`
: The hostname of the guacd instance to use to establish remote desktop
  connections. *This is required if you are not using Docker to provide guacd.*

`GUACD_PORT`
: The port that Guacamole should use when connecting to guacd. This environment
  variable is optional. If not provided, the standard guacd port of 4822 will
  be used.

The `GUACD_HOSTNAME` and, if necessary, `GUACD_PORT` environment variables can
thus be used in place of a Docker link if using a Docker link is impossible or
undesirable:

```console
$ docker run --name some-guacamole \
    -e GUACD_HOSTNAME=172.17.42.1  \
    -e GUACD_PORT=4822             \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

*A connection to guacd is not the only thing required for Guacamole to work*;
some authentication mechanism needs to be configured, as well.
[MySQL](guacamole-docker-mysql), [PostgreSQL](guacamole-docker-postgresql), and
[LDAP](guacamole-docker-ldap) are supported for this, and are described in more
detail in the sections below. If the required configuration options for at
least one authentication mechanism are not provided, the Guacamole image will
not be able to start up, and you will see an error.

(guacamole-docker-mysql)=

### MySQL authentication

To use Guacamole with the MySQL authentication backend, you will need either a
Docker container running the `mysql` image, or network access to a working
installation of MySQL. The connection to MySQL can be specified using either
environment variables or a Docker link.

(initializing-guacamole-docker-mysql)=

#### Initializing the MySQL database

If your database is not already initialized with the Guacamole schema, you will
need to do so prior to using Guacamole. A convenience script for generating the
necessary SQL to do this is included in the Guacamole image.

To generate a SQL script which can be used to initialize a fresh MySQL database
as documented in [](jdbc-auth):

```console
$ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
```

Alternatively, you can use the SQL scripts included with the database
authentication.

Once this script is generated, you must:

1. Create a database for Guacamole within MySQL, such as `guacamole_db`.

2. Create a user for Guacamole within MySQL with access to this database, such
   as `guacamole_user`.

3. Run the script on the newly-created database.

The process for doing this via the {command}`mysql` utility included with MySQL
is documented [](jdbc-auth).

(guacamole-docker-mysql-connecting)=

#### Connecting Guacamole to MySQL

If your MySQL database is provided by another Docker container, and you wish to
use a Docker link to connect the Guacamole image to your database, the
connection details are implied by the Docker link itself:

```console
$ docker run --name some-guacamole \
    --link some-guacd:guacd        \
    --link some-mysql:mysql        \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

If you are not using Docker to provide your MySQL database, you will need to
provide the network connection information yourself using additional
environment variables:

`MYSQL_HOSTNAME`
: The hostname of the database to use for Guacamole authentication. *This is
  required if you are not using Docker to provide your MySQL database.*

`MYSQL_PORT`
: The port that Guacamole should use when connecting to MySQL. This environment
  variable is optional. If not provided, the standard MySQL port of 3306 will
  be used.

The `MYSQL_HOSTNAME` and, if necessary, `MYSQL_PORT` environment variables can
thus be used in place of a Docker link if using a Docker link is impossible or
undesirable:

```console
$ docker run --name some-guacamole \
    --link some-guacd:guacd        \
    -e MYSQL_HOSTNAME=172.17.42.1  \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

Note that a Docker link to guacd (the `--link some-guacd:guacd` option above)
is not required any more than a Docker link is required for MySQL. The
connection information for guacd can be specified using environment variables,
as described in [](guacamole-docker-guacd).

(guacamole-docker-mysql-required-vars)=

#### Required environment variables

Using MySQL for authentication requires additional configuration parameters
specified via environment variables. These variables collectively describe how
Guacamole will connect to MySQL:

`MYSQL_DATABASE`
: The name of the database to use for Guacamole authentication.

`MYSQL_USER`
: The user that Guacamole will use to connect to MySQL.

`MYSQL_PASSWORD`
: The password that Guacamole will provide when connecting to MySQL as
  `MYSQL_USER`.

If any required environment variables are omitted, you will receive an error
message in the logs, and the image will stop. You will then need to recreate
the container with the proper variables specified.

(guacamole-docker-mysql-optional-vars)=

#### Optional environment variables

Additional optional environment variables may be used to override Guacamole's
default behavior with respect to concurrent connection use by one or more
users. Concurrent use of connections and connection groups can be limited to an
overall maximum and/or a per-user maximum:


`MYSQL_ABSOLUTE_MAX_CONNECTIONS`
: The absolute maximum number of concurrent connections to allow at any time,
  regardless of the Guacamole connection or user involved. If set to "0", this
  will be unlimited. Because this limit applies across all Guacamole
  connections, it cannot be overridden if set.

  *By default, the absolute total number of concurrent connections is unlimited
  ("0").*

`MYSQL_DEFAULT_MAX_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one Guacamole
  connection. If set to "0", this will be unlimited. This can be overridden on
  a per-connection basis when editing a connection.

  *By default, overall concurrent use of connections is unlimited ("0").*

`MYSQL_DEFAULT_MAX_GROUP_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one Guacamole
  connection group. If set to "0", this will be unlimited.  This can be
  overridden on a per-group basis when editing a connection group.

  *By default, overall concurrent use of connection groups is unlimited ("0").*

`MYSQL_DEFAULT_MAX_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow a single user to
  maintain to any one Guacamole connection. If set to "0", this will be
  unlimited. This can be overridden on a per-connection basis when editing a
  connection.

  *By default, per-user concurrent use of connections is unlimited ("0").*

`MYSQL_DEFAULT_MAX_GROUP_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow a single user to
  maintain to any one Guacamole connection group. If set to "0", this will be
  unlimited. This can be overridden on a per-group basis when editing a
  connection group.

  *By default, per-user concurrent use of connection groups is limited to one
  ("1")*, to prevent a balancing connection group from being completely
  exhausted by one user alone.

`MYSQL_AUTO_CREATE_ACCOUNTS`
: Whether or not accounts that do not exist in the MySQL database will be
  automatically created when successfully authenticated through other modules.
  If set to "true" accounts will be automatically created. Otherwise, and by
  default, accounts will not be automatically created and will need to be
  manually created in order for permissions within the MySQL database extension
  to be assigned to users authenticated with other modules.

(guacamole-docker-postgresql)=

### PostgreSQL authentication

To use Guacamole with the PostgreSQL authentication backend, you will
need either a Docker container running the `postgres` image, or
network access to a working installation of PostgreSQL. The connection
to PostgreSQL can be specified using either environment variables or a
Docker link.

(initializing-guacamole-docker-postgresql)=

#### Initializing the PostgreSQL database

If your database is not already initialized with the Guacamole schema, you will
need to do so prior to using Guacamole. A convenience script for generating the
necessary SQL to do this is included in the Guacamole image.

To generate a SQL script which can be used to initialize a fresh PostgreSQL
database as documented in [](jdbc-auth):

```console
$ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > initdb.sql
```

Alternatively, you can use the SQL scripts included with the database
authentication.

Once this script is generated, you must:

1. Create a database for Guacamole within PostgreSQL, such as
   `guacamole_db`.

2. Run the script on the newly-created database.

3. Create a user for Guacamole within PostgreSQL with access to the tables and
   sequences of this database, such as `guacamole_user`.

The process for doing this via the {command}`psql` and {command}`createdb`
utilities included with PostgreSQL is documented in [](jdbc-auth).

(guacamole-docker-postgresql-connecting)=

#### Connecting Guacamole to PostgreSQL

If your PostgreSQL database is provided by another Docker container, and you
wish to use a Docker link to connect the Guacamole image to your database, the
connection details are implied by the Docker link itself:

```console
$ docker run --name some-guacamole \
    --link some-guacd:guacd        \
    --link some-postgres:postgres  \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

If you are not using Docker to provide your PostgreSQL database, you will need
to provide the network connection information yourself using additional
environment variables:

`POSTGRESQL_HOSTNAME`
: The hostname of the database to use for Guacamole authentication. *This is
  required if you are not using Docker to provide your PostgreSQL database.*

`POSTGRESQL_PORT`
: The port that Guacamole should use when connecting to PostgreSQL. This
  environment variable is optional. If not provided, the standard PostgreSQL
  port of 5432 will be used.

The `POSTGRESQL_HOSTNAME` and, if necessary, `POSTGRESQL_PORT` environment
variables can thus be used in place of a Docker link if using a Docker link is
impossible or undesirable:

```console
$ docker run --name some-guacamole     \
    --link some-guacd:guacd            \
    -e POSTGRESQL_HOSTNAME=172.17.42.1 \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

Note that a Docker link to guacd (the `--link some-guacd:guacd` option above)
is not required any more than a Docker link is required for PostgreSQL. The
connection information for guacd can be specified using environment variables,
as described in [](guacamole-docker-guacd).

(guacamole-docker-postgresql-required-vars)=

#### Required environment variables

Using PostgreSQL for authentication requires additional configuration
parameters specified via environment variables. These variables collectively
describe how Guacamole will connect to PostgreSQL:

`POSTGRESQL_DATABASE`
: The name of the database to use for Guacamole authentication.

`POSTGRESQL_USER`
: The user that Guacamole will use to connect to PostgreSQL.

`POSTGRESQL_PASSWORD`
: The password that Guacamole will provide when connecting to PostgreSQL as
  `POSTGRESQL_USER`.

If any required environment variables are omitted, you will receive an
error message in the logs, and the image will stop. You will then need
to recreate the container with the proper variables specified.

(guacamole-docker-postgresql-optional-vars)=

#### Optional environment variables

Additional optional environment variables may be used to override Guacamole's
default behavior with respect to concurrent connection use by one or more
users. Concurrent use of connections and connection groups can be limited to an
overall maximum and/or a per-user maximum:

`POSTGRESQL_ABSOLUTE_MAX_CONNECTIONS`
: The absolute maximum number of concurrent connections to allow at any time,
  regardless of the Guacamole connection or user involved. If set to "0", this
  will be unlimited. Because this limit applies across all Guacamole
  connections, it cannot be overridden if set.

  *By default, the absolute total number of concurrent connections is unlimited
  ("0").*

`POSTGRESQL_DEFAULT_MAX_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one Guacamole
  connection. If set to "0", this will be unlimited. This can be overridden on
  a per-connection basis when editing a connection.

  *By default, overall concurrent use of connections is unlimited ("0").*

`POSTGRESQL_DEFAULT_MAX_GROUP_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one Guacamole
  connection group. If set to "0", this will be unlimited.  This can be
  overridden on a per-group basis when editing a connection group.

  *By default, overall concurrent use of connection groups is unlimited ("0").*

`POSTGRESQL_DEFAULT_MAX_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow a single user to
  maintain to any one Guacamole connection. If set to "0", this will be
  unlimited. This can be overridden on a per-connection basis when editing a
  connection.

  *By default, per-user concurrent use of connections is unlimited ("0").*

`POSTGRESQL_DEFAULT_MAX_GROUP_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow a single user to
  maintain to any one Guacamole connection group. If set to "0", this will be
  unlimited. This can be overridden on a per-group basis when editing a
  connection group.

  *By default, per-user concurrent use of connection groups is limited to one
  ("1")*, to prevent a balancing connection group from being completely
  exhausted by one user alone.

`POSTGRESQL_AUTO_CREATE_ACCOUNTS`
: Whether or not accounts that do not exist in the PostgreSQL database will be
  automatically created when successfully authenticated through other modules.
  If set to "true", accounts will be automatically created. Otherwise, and by
  default, accounts will not be automatically created and will need to be
  manually created in order for permissions within the PostgreSQL database
  extension to be assigned to users authenticated with other modules.

Optional environment variables may also be used to override Guacamole's default
behavior with respect to timeouts at the database and network level:

`POSTGRESQL_DEFAULT_STATEMENT_TIMEOUT`
: The number of seconds the driver will wait for a response from the database,
  before aborting the query. A value of 0 (the default) means the timeout is
  disabled.

`POSTGRESQL_SOCKET_TIMEOUT`
: The number of seconds to wait for socket read operations. If reading from the
  server takes longer than this value, the connection will be closed. This can
  be used to handle network problems such as a dropped connection to the
  database. Similar to `POSTGRESQL_DEFAULT_STATEMENT_TIMEOUT`, it will also abort
  queries that take too long. A value of 0 (the default) means the timeout is
  disabled.

(guacamole-docker-ldap)=

### LDAP authentication

To use Guacamole with the LDAP authentication backend, you will need network
access to an LDAP directory. Unlike MySQL and PostgreSQL, the Guacamole Docker
image does not support Docker links for LDAP; the connection information *must*
be specified using environment variables:


`LDAP_HOSTNAME`
: The hostname or IP address of your LDAP server.

`LDAP_PORT`
: The port your LDAP server listens on. By default, this will be 389 for
  unencrypted LDAP or LDAP using STARTTLS, and 636 for LDAP over SSL (LDAPS).

`LDAP_ENCRYPTION_METHOD`
: The encryption mechanism that Guacamole should use when communicating with
  your LDAP server. Legal values are "none" for unencrypted LDAP, "ssl" for
  LDAP over SSL/TLS (commonly known as LDAPS), or "starttls" for STARTTLS. If
  omitted, encryption will not be used.

Only the `LDAP_HOSTNAME` variable is required, but you may also need to specify
`LDAP_PORT` or `LDAP_ENCRYPTION_METHOD` if your LDAP directory uses encryption
or listens on a non-standard port:

```console
$ docker run --name some-guacamole \
    --link some-guacd:guacd        \
    -e LDAP_HOSTNAME=172.17.42.1   \
    ...
    -d -p 8080:8080 guacamole/guacamole
```

Note that a Docker link to guacd (the `--link some-guacd:guacd` option above)
is not required.  Similar to LDAP, the connection information for guacd can be
specified using environment variables, as described in [](guacamole-docker-guacd).

(guacamole-docker-ldap-required-vars)=

#### Required environment variables

Using LDAP for authentication requires additional configuration parameters
specified via environment variables. These variables collectively describe how
Guacamole will query your LDAP directory:

`LDAP_USER_BASE_DN`
: The base of the DN for all Guacamole users. All Guacamole users that will be
  authenticating against LDAP must be descendents of this base DN.

As with the other authentication mechanisms, if any required environment
variables are omitted (including those required for connecting to the LDAP
directory over the network), you will receive an error message in the logs, and
the image will stop. You will then need to recreate the container with the
proper variables specified.

(guacamole-docker-ldap-optional-vars)=

#### Optional environment variables

Additional optional environment variables may be used to configure the details
of your LDAP directory hierarchy, or to enable more flexible searching for user
accounts:

`LDAP_GROUP_BASE_DN`
: The base of the DN for all groups that may be referenced within Guacamole
  configurations using the standard seeAlso attribute. All groups which will be
  used to control access to Guacamole configurations must be descendents of
  this base DN. *If this variable is omitted, the seeAlso attribute will have
  no effect on Guacamole configurations.*

`LDAP_GROUP_SEARCH_FILTER`
: The search filter used to query the LDAP tree for groups that may be used by
  other extensions to define permissions. *If this property is omitted the
  default of `(objectClass=*)` will be used.*

`LDAP_GROUP_NAME_ATTRIBUTE`
: The attribute or attributes which define the unique name of user groups in
  the LDAP directory. Usually, and by default, this will simplify be "cn". If
  your LDAP directory contains groups whose names are dictated by different
  attributes, multiple attributes can be specified here, separated by
  commas.

`LDAP_MEMBER_ATTRIBUTE`
: The attribute which contains the members within all group objects in the
  LDAP directory. Usually, and by default, this will simply be "member". If
  your LDAP directory contains groups whose members are dictated by a
  different attribute it can be specified, here.

`LDAP_MEMBER_ATTRIBUTE_TYPE`
: Specify whether the attribute defined in `LDAP_MEMBER_ATTRIBUTE` identifies
  a group member by DN or usercode (user id). Valid values are "dn" (the
  default, if not specified) or "uid".

`LDAP_SEARCH_BIND_DN`
: The DN (Distinguished Name) of the user to bind as when authenticating users
  that are attempting to log in. If specified, Guacamole will query the LDAP
  directory to determine the DN of each user that logs in. If omitted, each
  user's DN will be derived directly using the base DN specified with
  `LDAP_USER_BASE_DN`.

`LDAP_SEARCH_BIND_PASSWORD`
: The password to provide to the LDAP server when binding as
  `LDAP_SEARCH_BIND_DN` to authenticate other users. This variable is only
  used if `LDAP_SEARCH_BIND_DN` is specified. If omitted, but
  `LDAP_SEARCH_BIND_DN` is specified, Guacamole will attempt to bind with the
  LDAP server without a password.

`LDAP_USERNAME_ATTRIBUTE`
: The attribute or attributes which contain the username within all Guacamole
  user objects in the LDAP directory. Usually, and by default, this will simply
  be "uid". If your LDAP directory contains users whose usernames are dictated
  by different attributes, multiple attributes can be specified here, separated
  by commas, but beware: *doing so requires that a search DN be provided with
  `LDAP_SEARCH_BIND_DN`*.

`LDAP_USER_ATTRIBUTES`
: The attribute or attributes to retrieve from the LDAP directory for users
  when they log in, with multiple attributes separated by commas. If specified,
  the attributes listed are retrieved from each authenticated users and
  dynamically applied to the parameters of that user's connections as
  parameter tokens with the prefix `LDAP_`.

`LDAP_CONFIG_BASE_DN`
: The base of the DN for all Guacamole configurations. If omitted, the
  configurations of Guacamole connections will simply not be queried from the
  LDAP directory, and you will need to store them elsewhere, such as within a
  MySQL or PostgreSQL database.

`LDAP_DEREFERENCE_ALIASES`
: Controls whether or not the LDAP connection follows (dereferences) aliases
  as it searches the tree. Possible values for this property are "never"
  (the default), so that aliases will never be followed, "searching", to
  dereference during the search operations after the base object is located,
  "finding", to dereference in order to locate the search base but not during
  the actual search, and "always", to always dereference aliases.

`LDAP_FOLLOW_REFERRALS`
: This option controls whether or not the LDAP module follows referrals when
  processing search results. Referrals can be pointers to another part of the
  current LDAP tree, or to a completely different tree altogether, hosted on
  a different server and/or port. Valid options are "false" (the default),
  which means that referrals will be ignored, or "true", where the client
  will attempt to follow the referrals in order to continue the search. The
  referral will be followed with the same credentials used to search the
  initial tree.

`LDAP_MAX_REFERRAL_HOPS`
: When LDAP referrals are enabled, this option controls how many hops the
  LDAP client will follow before refusing to continue. The default is 5.

`LDAP_MAX_SEARCH_RESULTS`
: The maximum number of search results that can be returned by a single LDAP
  query. LDAP queries which exceed this number of results may fail. By default
  the maximum number of results for a single LDAP query is 1000.

`LDAP_OPERATION_TIMEOUT`
: The timeout, in seconds, of any single LDAP operation, after which the
  operation will be aborted. The default is 30 seconds.

As documented in [](ldap-auth), Guacamole does support combining LDAP with a
MySQL or PostgreSQL database, and this can be configured with the Guacamole
Docker image, as well. Each of these authentication mechanisms is independently
configurable using their respective environment variables, and by providing the
required environment variables for multiple systems, Guacamole will
automatically be configured to use each when the Docker image starts.

(guacamole-docker-header-auth)=

### Header Authentication

The header authentication extension can be used to authenticate Guacamole
through a trusted third-party server, where the authenticated user's username
is passed back to Guacamole via a specific HTTP header. The following are
valid Docker variables for enabling and configuring header authentication:

`HEADER_ENABLED`
: Enables authentication via the header extension, which causes the extension
  to be loaded when Guacamole starts. By default this is false and the header
  extension will not be loaded.

`HTTP_AUTH_HEADER`
: Optional environment variable that, if set, configures the name of the HTTP
  header that will be used used to authenticate the user to Guacamole. If this
  is not specified the default value of REMOTE_USER will be used.

(guacamole-docker-saml-auth)=

### SAML Authentication

SAML authentication can be configured to allow the Guacamole Client instance
running in a Docker container to authentication with a SAML Identity Provider
(IdP). The IdP verifies the user authentication and then provides a response
back to Guacamole with the name of the user and any other configured
attributes contained in the SAML assertion. More details on SAML
authentication with Guacamole can be found on the [](saml-auth) page.

(guacamole-docker-saml-auth-required-vars)=

#### Required environment variables

Configuration of SAML authentication requires that either a metadata file
or a few other basic configuration parameters be provided to the container:

`SAML_IDP_METADATA_URL`
: The URI of a file that provides information about the SAML IdP that will
  be used to authenticate users. This can either be a local file on the
  filesystem, or it can be the URL of a file on a remote server. Note that
  if the file is located on a local filesystem it will have to be made
  available to the Docker container by either copying the file in or using
  a file located on a volume that is shared with the container. Metadata
  files for SAML authentication are generally obtained from the IdP.

`SAML_IDP_URL`
: If a metadata file is not provided, or does not contain the URL of the
  Identity Provider, then this variable must be present in order to
  tell Guacamole the location of the IdP, which is where users will be
  redirected for authentication.

`SAML_ENTITY_ID`
: The SAML Entity Identifier of the Guacamole Client instance that will
  be provided to the SAML IdP. This is generally the URL of the
  Guacamole server. If the metadata URL is not provided, or the
  metadata file does not contain an entity ID, this variable must
  be provided.

`SAML_CALLBACK_URL`
: The URL of the Guacamole instance that will be given to the SAML IdP,
  which will be used by the IdP to redirect the user back to the Guacamole
  instance after the user has been validated. If the metadata file is not
  provided, or does not contain a callback URL for the Guacamole instance,
  this variable must be provided.

(guacamole-docker-saml-auth-optional-vars)=

#### Optional environment variables

Other environment variables can be provided to adjust the behavior of the
SAML authentication extension.

`SAML_STRICT`
: A boolean value that configures whether or not the Guacamole SAML client
  will perform strict security checks on servers and certificates. This is
  normally enabled and should never be disabled in a production environment.

`SAML_COMPRESS_REQUEST`
: A boolean value that configures whether or not the Guacamole SAML client
  will enable compression on requests sent to the IdP. This defaults to
  enabled (true).

`SAML_COMPRESS_RESPONSE`
: A boolean value that configures whether or not the Guacamole SAML client
  will request that responses from the IdP be compressed. This defaults to
  enabled (true).

`SAML_GROUP_ATTRIBUTE`
: The name of the attribute within the SAML assertion that contains the
  group membership of the user who is being authenticated, if any. This
  property is optional and defaults to "groups".

`SAML_DEBUG`
: Whether or not the Guacamole SAML client should provide verbose logging
  that may be helpful in debugging problems with SAML authentication. This
  is optional and defaults to false - debugging will not be enabled.

(guacamole-docker-history-recording-storage)=

### History Recording Storage Extension

The extension that enables viewing historical recordings from within the
Guacamole Client interface can be enabled by settings the search path
variable, as noted below, to a location where the extension will look
to find available recordings.

When setting this up in a container environment, you'll likely need
to use volumes to make the same directory available to both the
guacd container and the guacamole (client) container. In addition
to setting up the volume to share data between the two, you'll also
need to configure permissions on the volume such that the users
running each of the containers have access. The guacamole/guacd
container, which will need write access to this shared location,
runs with an effective UID and GID of 1000. The guacamole/guacamole
(client) container, which will require read access to this location,
runs with an effective UID and GID of 1001.

For more information on this extension, please see the [](recording-playback)
page in the manual.

(guacamole-docker-history-recording-storage-required-vars)=

#### Required environment variables

In order to enable this extension you must set the following
environment variable in your guacamole container configuration:

`RECORDING_SEARCH_PATH`
: Set to the absolute path of the folder **within the guacamole container**
  where the extension should look for past recordings.

(guacamole-docker-tomcat-remote-ip-valve)=

### Running Guacamole behind a proxy

To run Guacamole behind a reverse proxy, Tomcat's
[`RemoteIpValve`](https://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Remote_IP_Valve)
must be configured as described in [](tomcat-remote-ip) to ensure that the
user's IP address can be correctly determined and logged. The Guacamole Docker
image provides environment variables for configuring this.

(guacamole-docker-tomcat-remote-ip-valve-required-vars)=

#### Required environment variables

The following environment variable must be set in order to configure Tomcat's
[`RemoteIpValve`](https://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Remote_IP_Valve):

`REMOTE_IP_VALVE_ENABLED`
: Set to `true` to enable Tomcat's [`RemoteIpValve`](https://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Remote_IP_Valve).
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
Guacamole within the image, you can still use them by providing a custom base
configuration using the `GUACAMOLE_HOME` environment variable:

`GUACAMOLE_HOME`
: The absolute path to the directory within the Docker container to use *as a
  template* for the image's automatically-generated [`GUACAMOLE_HOME`](guacamole-home).
  Any configuration generated by the Guacamole Docker image based on other
  environment variables will be applied to an independent copy of the contents
  of this directory.

You will *still* need to follow the steps required to create the contents of
[`GUACAMOLE_HOME`](guacamole-home) specific to your extension (placing the
extension itself within `GUACAMOLE_HOME/extensions/`, adding any properties to
`guacamole.properties`, etc.), but the rest of Guacamole's configuration will
be handled automatically, overlaid on top of a copy of the `GUACAMOLE_HOME` you
provide.

Because the Docker image's `GUACAMOLE_HOME` environment variable must point to
a directory *within the container*, you will need to expose your custom
`GUACAMOLE_HOME` to the container using the `-v` option of `docker run`. The
container directory chosen can then be referenced in the `GUACAMOLE_HOME`
environment variable, and the image will handle the rest automatically:

```console
$ docker run --name some-guacamole    \
    ...
    -v /local/path:/some-directory   \
    -e GUACAMOLE_HOME=/some-directory \
    -d -p 8080:8080 guacamole/guacamole
```

(extension-priority)=

### Extension priority and load order

Guacamole extensions are loaded and evaluated in a specific, deterministic
order. This order can be important when multiple authentication extensions are
installed, as it dictates which extensions will be given the first chance to
accept or reject a user's credentials. By default, this order is dictated by
the sort order of their corresponding filenames. If necessary, extension
priority can be overridden with the `EXTENSION_PRIORITY` environment variable.

`EXTENSION_PRIORITY`
: A comma-separated list of the namespaces of all extensions that should be
  loaded in a specific order. The special value `*` can be used in lieu of a
  namespace to represent all extensions that are not listed. All extensions
  explicitly listed will be sorted in the order given, while all extensions
  not explicitly listed will be sorted by their filenames.

  For example, to ensure support for SAML is loaded _first_:

  ```
  -e EXTENSION_PRIORITY="saml"
  ```

  Or to ensure support for SAML is loaded _last_:

  ```
  -e EXTENSION_PRIORITY="*, saml"
  ```

  If unsure which namespaces apply or the order that your extensions are
  loaded, check the Guacamole logs. The namespaces and load order of all
  installed extensions are logged by Guacamole during startup:

  ```
  ...
  23:32:06.467 [main] INFO  o.a.g.extension.ExtensionModule - Multiple extensions are installed and will be loaded in order of decreasing priority:
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [postgresql] "PostgreSQL Authentication" (/etc/guacamole/extensions/guacamole-auth-jdbc-postgresql-1.5.3.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [ldap] "LDAP Authentication" (/etc/guacamole/extensions/guacamole-auth-ldap-1.5.3.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [openid] "OpenID Authentication Extension" (/etc/guacamole/extensions/guacamole-auth-sso-openid-1.5.3.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule -  - [saml] "SAML Authentication Extension" (/etc/guacamole/extensions/guacamole-auth-sso-saml-1.5.3.jar)
  23:32:06.468 [main] INFO  o.a.g.extension.ExtensionModule - To change this order, set the "extension-priority" property or rename the extension files. The default priority of extensions is dictated by the sort order of their filenames.
  ...
  ```

(verifying-guacamole-docker)=

### Verifying the Guacamole install

Once the Guacamole image is running, Guacamole should be accessible at
{samp}`http://{HOSTNAME}:8080/guacamole/`, where `HOSTNAME` is the hostname or
address of the machine hosting Docker, and you *should* see a login screen. If
using MySQL or PostgreSQL, the database initialization scripts will have
created a default administrative user called "`guacadmin`" with the password
"`guacadmin`". *You should log in and change your password immediately.* If
using LDAP, you should be able to log in as any valid user within your LDAP
directory.

If you cannot access Guacamole, or you do not see a login screen, check
Docker's logs using the `docker logs` command to determine if something is
wrong. Configuration parameters may have been given incorrectly, or the
database may be improperly initialized:

```console
$ docker logs some-guacamole
```

