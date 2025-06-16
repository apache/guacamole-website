Database setup for MariaDB / MySQL
==================================

To use Guacamole with a MariaDB or MySQL database, you will need:

1. An instance of the MariaDB or MySQL database server.

2. Sufficient permission to create new databases, to create new users, and to
   grant those users permissions.

3. Network access to the database from the Guacamole server.

If this is not the case, install your database of choice now. Most
distributions will provide a convenient MariaDB or MySQL package which will set
up everything for you. If you prefer Docker, the [`mysql`](https://hub.docker.com/_/mysql)
and [`mariadb`](https://hub.docker.com/_/mariadb) Docker images are also
reasonable options. If you don't wish to use MariaDB or MySQL, Guacamole
additionally supports:

* [PostgreSQL](postgresql-auth)
* [SQL Server](sqlserver-auth)


```{include} include/warn-config-changes.md
```

(mysql-auth-database-creation)=

Creating a new database for Guacamole
-------------------------------------

It is best practice to use a dedicated database and user for the Guacamole web
application, and these instructions cover only this method.

If using the [`mariadb`](https://hub.docker.com/_/mariadb) or [`mysql`](https://hub.docker.com/_/mysql) Docker images:
: Set the `MARIADB_DATABASE` or `MYSQL_DATABASE` environment variables
  respectively to the desired name of the database. The Docker image will
  automatically create this database when the container starts for the first
  time.

If using a native installation of MariaDB or MySQL:
: Manually create a database for MySQL and MariaDB by executing a
  `CREATE DATABASE` query with the `mysql` client:

  ```mysql
  CREATE DATABASE guacamole_db;
  ```

### Initializing the database

::::{tab} Native Webapp (Tomcat)
The schema scripts necessary to initialize the MySQL version of Guacamole's
database are provided within the `mysql/schema/` directory of [`guacamole-auth-jdbc-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz?action=download),
which must be downloaded from [the release page for Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
and extracted first.

Running each of these scripts against the newly created database will
initialize it with Guacamole's schema. You can run these scripts using the
standard `mysql` client, but the method of running `mysql` varies depending on
whether you are using Docker to provide your database.

If using the [`mariadb`](https://hub.docker.com/_/mariadb) or [`mysql`](https://hub.docker.com/_/mysql) Docker images:
: The schema initialization scripts should be run against the newly created
  database by running the standard `mysql` command-line client _within the
  container_:

  ```console
  $ cat schema/*.sql | docker exec -i some-mysql \
      sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" guacamole_db'
  ```

If using a native installation of MariaDB or MySQL:
: The schema initialization scripts should be run against the newly created
  database using the standard `mysql` client directly from the command-line:

  ```console
  $ cat schema/*.sql | mysql -u root -p guacamole_db
  Enter password:
  $
  ```
::::

::::{tab} Container (Docker)
The schema scripts necessary to initialize the MySQL version of Guacamole's
database are provided within the `/opt/guacamole/extensions/guacamole-auth-jdbc/mysql/schema`
directory of the `guacamole/guacamole` image.

Additionally, an `initdb.sh` script is provided at `/opt/guacamole/bin/initdb.sh`
that can be used to extract the required schema initialization script:

```console
$ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
```

If using the [`mariadb`](https://hub.docker.com/_/mariadb) or [`mysql`](https://hub.docker.com/_/mysql) Docker images via Docker Compose:
: 
  The easiest way to initialize Guacamole's database is to use a volume mount to
  map the bundled schema initialization scripts from the Guacamole container into
  the database container. For example, if using Docker Compose:
  
  1. Declare a named volume at the root level of your `docker-compose.yml`:
  
     ```yaml
     volumes:
         initdb:
     ```
  
  2. Reference the named volume within your Guacamole service, effectively
     pulling the schema initialization scripts from that container and into the
     volume:
  
     ```yaml
     volumes:
         - "initdb:/opt/guacamole/extensions/guacamole-auth-jdbc/mysql/schema:ro"
     ```
  
  3. Reference the named volume within your database service, bringing the
     schema initialization scripts into the directory used by the database
     image for one-time initialization:
  
     ```yaml
     volumes:
         - "initdb:/docker-entrypoint-initdb.d:ro"
     ```
  


If using the [`mariadb`](https://hub.docker.com/_/mariadb) or [`mysql`](https://hub.docker.com/_/mysql) Docker images _without_ Docker Compose:
: Use the `initdb.sh` script included with the `guacamole/guacamole` image to
  send the required initialization script to the standard `mysql` command-line
  client _within the database container_:

  ```console
  $ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql | \
      docker exec -i some-mysql sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" guacamole_db'
  ```

If using a native installation of MariaDB or MySQL:
: Use the `initdb.sh` script included with the `guacamole/guacamole` image to
  automatically produce the SQL required to initialize an existing database:

  ```console
  $ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql | \
      mysql -u root -p guacamole_db
  ```
::::

### Granting Guacamole access to the database

For Guacamole to be able to execute queries against the database, you must
create a new user for the database and grant that user sufficient privileges to
manage the contents of all tables in the database.

If using the [`mariadb`](https://hub.docker.com/_/mariadb) or [`mysql`](https://hub.docker.com/_/mysql) Docker images:
: Set the `MARIADB_USER` or `MYSQL_USER` environment variables respectively to
  the desired name of the dedicated user, and the `MARIADB_PASSWORD` (or
  `MYSQL_PASSWORD`) environment variable to the desired password. The Docker
  image will automatically create this user when the container starts and grant
  them full access to the Guacamole database.

If using a native installation of MariaDB or MySQL:
: The dedicated user for Guacamole must be manually created and granted
  sufficient privileges. The user created for Guacamole needs only `SELECT`,
  `UPDATE`, `INSERT`, and `DELETE` permissions on all tables in the Guacamole
  database.

  ```mysql
  CREATE USER 'guacamole_user' IDENTIFIED BY 'some_password';
  GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user';
  FLUSH PRIVILEGES;
  ```

(mysql-auth-installation)=

Upgrading an existing Guacamole database
----------------------------------------

If you are upgrading from a version of Guacamole older than 1.6.0, you
may need to run one or more database schema upgrade scripts located within the
`mysql/schema/upgrade/` directory of [`guacamole-auth-jdbc-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz?action=download)
(available from [the release page for Apache Guacamole
1.6.0](https://guacamole.apache.org/releases/1.6.0)).

Each of these scripts is named {samp}`upgrade-pre-{VERSION}.sql` where
`VERSION` is the version of Guacamole where those changes were introduced. They
need to be run when you are upgrading from a version of Guacamole older than
`VERSION`.

If there are no {samp}`upgrade-pre-{VERSION}.sql` scripts present in the
`schema/upgrade/` directory which apply to your existing Guacamole database,
then the schema has not changed between your version and the version your are
installing, and there is no need to run any database upgrade scripts.

These scripts are incremental and, when relevant, *must be run in order*. For
example, if you are upgrading an existing database from version
0.9.13-incubating to version 1.0.0, you would need to run the
`upgrade-pre-0.9.14.sql` script (because 0.9.13-incubating is older than
0.9.14), followed by the `upgrade-pre-1.0.0.sql` script (because
0.9.13-incubating is also older than 1.0.0).

Installing/Enabling support for MariaDB/MySQL
---------------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:

1. You should have a copy of [`guacamole-auth-jdbc-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz?action=download) from
   earlier when you [created and initialized the database](mysql-auth-database-creation).

2. Create the `GUACAMOLE_HOME/extensions` and `GUACAMOLE_HOME/lib` directories,
   if they do not already exist.

3. Copy `mysql/guacamole-auth-jdbc-mysql-1.6.0.jar`
   within `GUACAMOLE_HOME/extensions`.

4. Copy the JDBC driver for your database to `GUACAMOLE_HOME/lib`. 
   Either of the following MySQL-compatible JDBC drivers are supported
   for connecting Guacamole with MariaDB or MySQL:

   * [MariaDB Connector/J](https://mariadb.com/kb/en/about-mariadb-connector-j/)
   * [MySQL Connector/J](http://dev.mysql.com/downloads/connector/j/) (the required `.jar` will be within a `.tar.gz` archive)

   If you do not have a specific reason to use one driver over the other, it's
   recommended that you use the JDBC driver provided by your database vendor.


5. Configure Guacamole to use database authentication, as described below.


:::{note}
Download and documentation links for all officially supported extensions for a
particular version of Guacamole are always provided in the release notes for
that version. The copy of the documentation you are reading now is from [Apache
Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0).

**If you are using a different version of Guacamole, please locate that version
within [the release archives](https://guacamole.apache.org/releases/) and
consult the documentation for that release instead.**
:::
::::

::::{tab} Container (Docker)
Docker installations of Guacamole include a bundled copy of [Apache
Tomcat](https://tomcat.apache.org/) and are configured using environment
variables. The startup process of the Docker image automatically populates
`GUACAMOLE_HOME` ([Guacamole's configuration directory](guacamole-home)) based
on the values of these variables.

If deploying Guacamole using Docker Compose:
: You will need to add at least one relevant environment variable to the
  `environment` section of your `guacamole/guacamole` container, such as the
  `MYSQL_ENABLED` environment variable:

  ```yaml
  MYSQL_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e MYSQL_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `MYSQL_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `MYSQL_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

:::{important}
**Older versions of MySQL Connector/J have known issues with SSL
verification.** If you experience problems connecting to SSL-secured MySQL
databases, it is recommended that you update to a current version of the
driver.
:::


(mysql-auth-configuration)=

Required configuration
----------------------

Additional configuration options must be specified for Guacamole to properly
connect to your database. These options are specific to the database being
used, and must be set correctly for authentication to work.

The options absolutely required by the database authentication extension are
relatively few and self-explanatory, describing only which database will be
used and how Guacamole will authenticate when querying that database:

::::{tab} Native Webapp (Tomcat)
If deploying Guacamole natively, you will need to add a section to your
`guacamole.properties` that looks like the following:

```ini
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: some_password
```

The properties that must be set in all cases for any Guacamole installation
using this extension are:


`mysql-database`
: The name of the database that you created for Guacamole. This is given as
  "guacamole_db" in the examples given in this chapter.

`mysql-username`
: The username of the user that Guacamole should use to connect to the
  database.  This is given as "guacamole_user" in the examples given in this
  chapter.

`mysql-password`
: The password Guacamole should provide when authenticating with the database.
  This is given as "some_password" in the examples given in this chapter.
::::

::::{tab} Container (Docker)
If deploying Guacamole using Docker Compose, you will need to add a set of
environment variables to the `environment` section of your
`guacamole/guacamole` container that looks like the following:

```yaml
MYSQL_DATABASE: 'guacamole_db'
MYSQL_USERNAME: 'guacamole_user'
MYSQL_PASSWORD: 'some_password'
```

If instead deploying Guacamole by running `docker run` manually, these same
environment variables will need to be provided using the `-e` option.  For
example:

```console
$ docker run --name some-guacamole \
    -e MYSQL_DATABASE="guacamole_db" \
    -e MYSQL_USERNAME="guacamole_user" \
    -e MYSQL_PASSWORD="some_password" \
    -d -p 8080:8080 guacamole/guacamole
```

The environment variables that must be set in all cases for any Docker-based
Guacamole installation using this extension are:


`MYSQL_DATABASE`
: The name of the database that you created for Guacamole. This is given as
  "guacamole_db" in the examples given in this chapter.

`MYSQL_USERNAME`
: The username of the user that Guacamole should use to connect to the
  database.  This is given as "guacamole_user" in the examples given in this
  chapter.

`MYSQL_PASSWORD`
: The password Guacamole should provide when authenticating with the database.
  This is given as "some_password" in the examples given in this chapter.
::::

:::{hint}
**Double-check these values.** You will not be able to sign into Guacamole
after installation if these parameters do not match the correct database name,
username, and password.
:::

Additional configuration (optional)
-----------------------------------

Additional options are available to control how Guacamole connects to the
database server:

::::{tab} Native Webapp (Tomcat)


`mysql-hostname`
: The hostname or IP address of the server hosting your database. If not
  specified, "localhost" will be used by default.

`mysql-port`
: The port number of the MySQL or MariaDB database to connect to. If not
  specified, the standard MySQL / MariaDB port 3306 will be used.

`mysql-driver`
: Controls which JDBC driver the extension attempts to load. By default, the
  installed JDBC driver will be automatically detected. Possible values are:
  
  mysql
  : [The **MySQL** Connector/J JDBC driver](https://dev.mysql.com/downloads/connector/j/).
  
  mariadb
  : [The **MariaDB** Connector/J JDBC driver](https://mariadb.com/kb/en/about-mariadb-connector-j/).

`mysql-server-timezone`
: Specifies the timezone the MySQL server is configured to run in. While the
  MySQL driver attempts to auto-detect the timezone in use by the server, there
  are many cases where the timezone provided by the operating system is either
  unknown by Java, or matches multiple timezones. In these cases MySQL may
  either complain or refuse the connection unless the timezone is specified as
  part of the connection. This property allows the timezone of the server to be
  specified so that the connection can continue and the JDBC driver can
  properly translate timestamps.  The property accepts timezones in the
  following formats:
  
  Region/Locale
  : Well-known time zone identifiers, in the Region/Locale format, as defined
    by the [IANA time zone database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones),
    such as `America/Los_Angeles`, `Africa/Johannesburg`, or `China/Shanghai`.
  
  GMT+/-HH:MM
  : GMT or custom timezones specified by GMT offset, such as `GMT`, `GMT+0130`,
    `GMT+06:00`, or `GMT-9`.

`mysql-ssl-mode`
: This property sets the SSL mode that the JDBC driver will attempt to use when
  communicating with the remote MySQL server. The values for this property
  match the standard values supported by the MySQL and MariaDB JDBC drivers:
  
  disabled
  : Do not use SSL, and fail if the server requires it. For compatibility this
    will also set the legacy JDBC driver property useSSL to false.
  
  preferred
  : Prefer SSL, but fall back to plain-text if an SSL connection cannot be
    negotiated. This is the default.
  
  required
  : Require SSL connections, and fail if SSL cannot be negotiated. This mode
    does not perform any validition checks on the certificate in use by the
    server, the issuer, etc.
  
  verify-ca
  : Require SSL connections, and check to make sure that the certificate issuer
    is known to be valid.
  
  verify-identity
  : Require SSL connections, and check to make sure that the server certificate
    is issued by a known authority, and that the identity of the server
    matches the identity on the certificate.

`mysql-ssl-trust-store`
: The file that will store trusted SSL certificates for the JDBC driver to use
  when validating CA and server certificates. This should be a JKS-formatted
  certificate store. This property is optional and defaults to Java's normal
  trusted certificate locations, which vary based on the version of Java in
  use.

`mysql-ssl-trust-password`
: The password to use to access the SSL trusted certificate store, if one is
  required. By default no password will be used.

`mysql-ssl-client-store`
: The file that contains the client certificate to use when making SSL
  connections to the MySQL server. This should be a JKS-formatted certificate
  store that contains a private key and certificate pair. This property is
  optional, and by default no client certificate will be used for the SSL
  connection.

`mysql-ssl-client-password`
: The password to use to access the client certificate store, if one is
  required. By default no password will be used.

`mysql-batch-size`
: Controls how many objects may be retrieved from the database in a single
  query. If more objects than this number are requested, retrieval of those
  objects will be automatically and transparently split across multiple
  queries.
  
  By default, MySQL/MariaDB queries will retrieve no more than 1000 objects.
::::

::::{tab} Container (Docker)


`MYSQL_HOSTNAME`
: The hostname or IP address of the server hosting your database. If not
  specified, "localhost" will be used by default.

`MYSQL_PORT`
: The port number of the MySQL or MariaDB database to connect to. If not
  specified, the standard MySQL / MariaDB port 3306 will be used.

`MYSQL_DRIVER`
: Controls which JDBC driver the extension attempts to load. By default, the
  installed JDBC driver will be automatically detected. Possible values are:
  
  mysql
  : [The **MySQL** Connector/J JDBC driver](https://dev.mysql.com/downloads/connector/j/).
  
  mariadb
  : [The **MariaDB** Connector/J JDBC driver](https://mariadb.com/kb/en/about-mariadb-connector-j/).

`MYSQL_SERVER_TIMEZONE`
: Specifies the timezone the MySQL server is configured to run in. While the
  MySQL driver attempts to auto-detect the timezone in use by the server, there
  are many cases where the timezone provided by the operating system is either
  unknown by Java, or matches multiple timezones. In these cases MySQL may
  either complain or refuse the connection unless the timezone is specified as
  part of the connection. This property allows the timezone of the server to be
  specified so that the connection can continue and the JDBC driver can
  properly translate timestamps.  The property accepts timezones in the
  following formats:
  
  Region/Locale
  : Well-known time zone identifiers, in the Region/Locale format, as defined
    by the [IANA time zone database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones),
    such as `America/Los_Angeles`, `Africa/Johannesburg`, or `China/Shanghai`.
  
  GMT+/-HH:MM
  : GMT or custom timezones specified by GMT offset, such as `GMT`, `GMT+0130`,
    `GMT+06:00`, or `GMT-9`.

`MYSQL_SSL_MODE`
: This property sets the SSL mode that the JDBC driver will attempt to use when
  communicating with the remote MySQL server. The values for this property
  match the standard values supported by the MySQL and MariaDB JDBC drivers:
  
  disabled
  : Do not use SSL, and fail if the server requires it. For compatibility this
    will also set the legacy JDBC driver property useSSL to false.
  
  preferred
  : Prefer SSL, but fall back to plain-text if an SSL connection cannot be
    negotiated. This is the default.
  
  required
  : Require SSL connections, and fail if SSL cannot be negotiated. This mode
    does not perform any validition checks on the certificate in use by the
    server, the issuer, etc.
  
  verify-ca
  : Require SSL connections, and check to make sure that the certificate issuer
    is known to be valid.
  
  verify-identity
  : Require SSL connections, and check to make sure that the server certificate
    is issued by a known authority, and that the identity of the server
    matches the identity on the certificate.

`MYSQL_SSL_TRUST_STORE`
: The file that will store trusted SSL certificates for the JDBC driver to use
  when validating CA and server certificates. This should be a JKS-formatted
  certificate store. This property is optional and defaults to Java's normal
  trusted certificate locations, which vary based on the version of Java in
  use.

`MYSQL_SSL_TRUST_PASSWORD`
: The password to use to access the SSL trusted certificate store, if one is
  required. By default no password will be used.

`MYSQL_SSL_CLIENT_STORE`
: The file that contains the client certificate to use when making SSL
  connections to the MySQL server. This should be a JKS-formatted certificate
  store that contains a private key and certificate pair. This property is
  optional, and by default no client certificate will be used for the SSL
  connection.

`MYSQL_SSL_CLIENT_PASSWORD`
: The password to use to access the client certificate store, if one is
  required. By default no password will be used.

`MYSQL_BATCH_SIZE`
: Controls how many objects may be retrieved from the database in a single
  query. If more objects than this number are requested, retrieval of those
  objects will be automatically and transparently split across multiple
  queries.
  
  By default, MySQL/MariaDB queries will retrieve no more than 1000 objects.
::::

### Enforcing password policies

Configuration options are available for enforcing rules intended to encourage
password complexity and regular changing of passwords. None of these options
are enabled by default, but can be selectively enabled as needed.

#### Password complexity

Administrators can require that passwords have a certain level of complexity,
such as having both uppercase and lowercase letters ("multiple case"), at least
one digit, or at least one symbol, and can prohibit passwords from containing
the user's own username.

With respect to password content, the database authentication defines a "digit"
as any numeric character and a "symbol" is any non-alphanumeric character. This
takes non-English languages into account, thus a digit is not simply "0"
through "9" but rather [any character defined in Unicode as
numeric](https://en.wikipedia.org/wiki/Numerals_in_Unicode), and a symbol is
any character which Unicode does not define as alphabetic or numeric.

The check for whether a password contains the user's own username is performed
in a case-insensitive manner. For example, if the user's username is "phil",
the passwords "ch!0roPhil" and "PHIL-o-dendr0n" would still be prohibited.

::::{tab} Native Webapp (Tomcat)


`mysql-user-password-min-length`
: The minimum length required of all user passwords, in characters. By default,
  password length is not enforced.

`mysql-user-password-require-multiple-case`
: Whether all user passwords must have at least one lowercase character and one
  uppercase character. By default, no such restriction is imposed.

`mysql-user-password-require-symbol`
: Whether all user passwords must have at least one non-alphanumeric character
  (symbol). By default, no such restriction is imposed.

`mysql-user-password-require-digit`
: Whether all user passwords must have at least one numeric character (digit).
  By default, no such restriction is imposed.

`mysql-user-password-prohibit-username`
: Whether users are prohibited from including their own username in their
  password. By default, no such restriction is imposed.
::::

::::{tab} Container (Docker)


`MYSQL_USER_PASSWORD_MIN_LENGTH`
: The minimum length required of all user passwords, in characters. By default,
  password length is not enforced.

`MYSQL_USER_PASSWORD_REQUIRE_MULTIPLE_CASE`
: Whether all user passwords must have at least one lowercase character and one
  uppercase character. By default, no such restriction is imposed.

`MYSQL_USER_PASSWORD_REQUIRE_SYMBOL`
: Whether all user passwords must have at least one non-alphanumeric character
  (symbol). By default, no such restriction is imposed.

`MYSQL_USER_PASSWORD_REQUIRE_DIGIT`
: Whether all user passwords must have at least one numeric character (digit).
  By default, no such restriction is imposed.

`MYSQL_USER_PASSWORD_PROHIBIT_USERNAME`
: Whether users are prohibited from including their own username in their
  password. By default, no such restriction is imposed.
::::

#### Password age / expiration

"Password age" refers to two separate concepts:

1. Requiring users to change their password after a certain amount of time has
   elapsed since the last password change (maximum password age).

2. Preventing users from changing their password too frequently (minimum
   password age).

While it may seem strange to prevent users from changing their password too
frequently, it does make sense if you are concerned that rapid password changes
may defeat password expiration (users could immediately change the password
back) or tracking of password history (users could cycle through passwords
until the history is exhausted and their old password is usable again).

By default, the database authentication does not apply any limits to password
age, and users with permission to change their passwords may do so as
frequently or infrequently as they wish. Password age limits can be enabled
using a pair of configuration options, each accepting values given in units of
days:

::::{tab} Native Webapp (Tomcat)


`mysql-user-password-min-age`
: The minimum number of days which must elapse before a user may reset their
  password, where zero represents no limit. By default, no minimum number of
  days is required.

`mysql-user-password-max-age`
: The maximum number of days which may elapse before a user is automatically
  required to reset their password, where zero represents no limit. By default,
  users are not automatically required to reset their password based on
  password age.
::::

::::{tab} Container (Docker)


`MYSQL_USER_PASSWORD_MIN_AGE`
: The minimum number of days which must elapse before a user may reset their
  password, where zero represents no limit. By default, no minimum number of
  days is required.

`MYSQL_USER_PASSWORD_MAX_AGE`
: The maximum number of days which may elapse before a user is automatically
  required to reset their password, where zero represents no limit. By default,
  users are not automatically required to reset their password based on
  password age.
::::

:::{important}
So that administrators can always intervene in the case that a password needs
to be reset despite restrictions, the minimum age restriction does not apply to
any user with permission to administer the system.
:::

#### Preventing password reuse

If desired, Guacamole can keep track of each user's most recently used
passwords, and will prohibit reuse of those passwords until the password has
been changed sufficiently many times. By default, Guacamole will not keep track
of old passwords.

Note that these passwords are hashed in the same manner as each user's current
password. When a user's password is changed, the hash, salt, etc. currently
stored for that user is actually just copied verbatim (along with a timestamp)
into a list of historical passwords, with older entries from this list being
automatically deleted.

::::{tab} Native Webapp (Tomcat)


`mysql-user-password-history-size`
: The number of previous passwords remembered for each user, where zero
  represents no history. If set to a non-zero value, users will be restricted
  from reusing any password in their password history. Passwords are remembered
  only in hashed and salted form. By default, previous passwords are not
  remembered and no such restriction is enforced.
::::

::::{tab} Container (Docker)


`MYSQL_USER_PASSWORD_HISTORY_SIZE`
: The number of previous passwords remembered for each user, where zero
  represents no history. If set to a non-zero value, users will be restricted
  from reusing any password in their password history. Passwords are remembered
  only in hashed and salted form. By default, previous passwords are not
  remembered and no such restriction is enforced.
::::

(mysql-auth-concurrency)=

### Concurrent use of Guacamole connections

The database authentication module provides configuration options to restrict
concurrent use of connections and connection groups. Concurrent use can be
restricted broadly or to ensure that each individual user may only maintain a
limited number of active connections to any one connection or group.

By default, concurrent usage is unrestricted except that each user may only
have a single active connection to each connection group. This is intended to
avoid the case that a single user is able to exhaust the contents of a
connection group and effectively block others from using the same resources.

If you wish to impose an absolute limit on the number of active connections
that can be established through Guacamole, ignoring which users or connections
are involved, this can be done as well.

The default policy set through these options can be overridden later on a
per-connection basis using the administrative interface.

::::{tab} Native Webapp (Tomcat)


`mysql-default-max-connections`
: The maximum number of concurrent connections to allow to any one connection,
  regardless of which user is accessing the connection, where zero denotes
  unlimited. By default, overall concurrent access to individual connections is
  not limited.

`mysql-default-max-group-connections`
: The maximum number of concurrent connections to allow to any one connection
  group, regardless of which user is accessing the connection group, where zero
  denotes unlimited. By default, overall concurrent access to individual
  connection groups is not limited.

`mysql-default-max-connections-per-user`
: The maximum number of concurrent connections to allow to any one connection
  by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to individual connections is not limited.

`mysql-default-max-group-connections-per-user`
: The maximum number of concurrent connections to allow to any one connection
  group by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to connection groups is limited to one user.

`mysql-absolute-max-connections`
: The maximum number of concurrent connections to allow overall, regardless of
  which connection or connection group is used and regardless of which user is
  accessing the connection/group, where zero denotes unlimited. By default,
  overall concurrent access to Guacamole is not limited.
::::

::::{tab} Container (Docker)


`MYSQL_DEFAULT_MAX_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one connection,
  regardless of which user is accessing the connection, where zero denotes
  unlimited. By default, overall concurrent access to individual connections is
  not limited.

`MYSQL_DEFAULT_MAX_GROUP_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one connection
  group, regardless of which user is accessing the connection group, where zero
  denotes unlimited. By default, overall concurrent access to individual
  connection groups is not limited.

`MYSQL_DEFAULT_MAX_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow to any one connection
  by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to individual connections is not limited.

`MYSQL_DEFAULT_MAX_GROUP_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow to any one connection
  group by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to connection groups is limited to one user.

`MYSQL_ABSOLUTE_MAX_CONNECTIONS`
: The maximum number of concurrent connections to allow overall, regardless of
  which connection or connection group is used and regardless of which user is
  accessing the connection/group, where zero denotes unlimited. By default,
  overall concurrent access to Guacamole is not limited.
::::

(mysql-auth-restrict)=

### External users and connections

When [combining LDAP with a database](ldap-and-database), or using a single
sign-on system like [OpenID Connect](openid-auth) or [SAML](saml-auth), user
accounts are not purely defined by Guacamole's database. They are additionally
defined by the relevant external system. In some cases, such as the [LDAP
extension's capability to retrieve connection information from the LDAP
directory](ldap-schema-changes), connections are not purely defined by
Guacamole's database either.

In these cases, it may be desirable to:

* Limit use of Guacamole to only those users that _do_ already exist in the
  database.

* Automatically create users in the database when they have successfully
  authenticated through other means, such that extensions requiring storage
  like TOTP can be used alongside SSO solutions.

* Control whether the database logs connection usage history for connections
  that are not maintained by the database.

By default, users will be allowed access to Guacamole as long as they are
authenticated by at least one extension, no extension denies/vetoes access, and
the database will record connection history entries for all connections
regardless of whether they are maintained by the database.

:::{note}
In all cases, users will only be able to see or interact with resources that
they have been given permission to access. This is true whether those
permissions are granted explicitly or through inheritance (from user groups).
:::

::::{tab} Native Webapp (Tomcat)


`mysql-user-required`
: Whether a user account within the database is required for authentication to
  succeed, even if the user has been authenticated via another extension. By
  default, successful authentication via any extension is sufficient, and
  database user accounts are not strictly required.

`mysql-auto-create-accounts`
: Whether to automatically create user accounts in the database for users who
  have successfully authenticate through another extension. Users that are
  automatically created are granted `READ` permission on their own user account
  and no other explicit permissions. By default users will not be automatically
  created.

`mysql-track-external-connection-history`
: Whether connection history records should be created for connections not
  defined in the database. By default, external connection history will be
  tracked unless this is explicitly disabled by setting this to "false".
::::

::::{tab} Container (Docker)


`MYSQL_USER_REQUIRED`
: Whether a user account within the database is required for authentication to
  succeed, even if the user has been authenticated via another extension. By
  default, successful authentication via any extension is sufficient, and
  database user accounts are not strictly required.

`MYSQL_AUTO_CREATE_ACCOUNTS`
: Whether to automatically create user accounts in the database for users who
  have successfully authenticate through another extension. Users that are
  automatically created are granted `READ` permission on their own user account
  and no other explicit permissions. By default users will not be automatically
  created.

`MYSQL_TRACK_EXTERNAL_CONNECTION_HISTORY`
: Whether connection history records should be created for connections not
  defined in the database. By default, external connection history will be
  tracked unless this is explicitly disabled by setting this to "false".
::::

### Access window enforcment

Guacamole supports the use of access windows to limit the time periods during
which users are allowed to access the system. By default, users will be
forcibly logged out from Guacamole as soon as the access window expires,
disconnecting them from any active connections.

If you would prefer users to be allowed to remain logged in, this behavior can
be overridden using the configuration option below.

:::{note}
Prior to [Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0),
access windows were enforced only during the login process. Access windows
restricted only when a user could log in, not whether they could remain logged
in.
:::

::::{tab} Native Webapp (Tomcat)


`mysql-enforce-access-windows-for-active-sessions`
: Whether time-based access windows should be enforced for active user sessions.
  By default, users will be logged out when an access window closes, even if
  they are currently logged in. To allow logged-in users to continue to use the
  application after an access window closes, set this to "false". Users will
  always be prevented from logging in outside of access windows regardless of
  this setting.
::::

::::{tab} Container (Docker)


`MYSQL_ENFORCE_ACCESS_WINDOWS_FOR_ACTIVE_SESSIONS`
: Whether time-based access windows should be enforced for active user sessions.
  By default, users will be logged out when an access window closes, even if
  they are currently logged in. To allow logged-in users to continue to use the
  application after an access window closes, set this to "false". Users will
  always be prevented from logging in outside of access windows regardless of
  this setting.
::::



Completing installation
-----------------------

```{include} include/ext-completing.md
```

(mysql-auth-default-user)=

Logging in
----------

```{include} include/jdbc-default-user.md
```
