Database setup for SQL Server
=============================

To use Guacamole with a SQL Server database, you will need:

1. An instance of the SQL Server database server.

2. Sufficient permission to create new databases, to create new users, and to
   grant those users permissions.

3. Network access to the database from the Guacamole server.

If this is not the case, you will need to install SQL Server before continuing
or use a different database. Guacamole additionally supports:

* [MariaDB / MySQL](mysql-auth)
* [PostgreSQL](postgresql-auth)

```{include} include/warn-config-changes.md
```

(sqlserver-auth-database-creation)=

Creating the Guacamole database
-------------------------------

It is best practice to use a dedicated database and user for the Guacamole web
application, and these instructions cover only this method.

To create the database within SQL Server, execute a `CREATE DATABASE` command
with the `sqlcmd` client:

```console
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA
Password:
1> CREATE DATABASE guacamole_db;
2> GO
1> quit
```

### Initializing the database

::::{tab} Native Webapp (Tomcat)
The schema scripts necessary to initialize the SQL Server version of Guacamole's
database are provided within the `sqlserver/schema/` directory of [`guacamole-auth-jdbc-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz?action=download),
which must be downloaded from [the release page for Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
and extracted first.

Running each the two scripts in the `sqlserver/schema/` directory against the
newly created database will initialize it with Guacamole's schema. You can run
these scripts using the standard `sqlcmd` client:

```console
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -d guacamole_db -i schema/001-create-schema.sql
Password:
Rule bound to data type.
The new rule has been bound to column(s) of the specified user data type.
Rule bound to data type.
The new rule has been bound to column(s) of the specified user data type.
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -d guacamole_db -i schema/002-create-admin-user.sql
Password:

(1 rows affected)

(3 rows affected)

(5 rows affected)
$
```
::::

::::{tab} Container (Docker)
The schema scripts necessary to initialize the SQL Server version of Guacamole's
database are provided within the `/opt/guacamole/extensions/guacamole-auth-jdbc/sqlserver/schema`
directory of the `guacamole/guacamole` image.

Additionally, an `initdb.sh` script is provided at `/opt/guacamole/bin/initdb.sh`
that can be used to extract the required schema initialization script:

```console
$ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --sqlserver > initdb.sql
```

The resulting script can then be run using the `sqlcmd` client:

```console
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -d guacamole_db -i initdb.sql
```
::::

Granting Guacamole access to the database
-----------------------------------------

For Guacamole to be able to execute queries against the database, you must
create a new user for the database and grant that user sufficient privileges to
manage the contents of all tables in the database.

The user created for Guacamole needs only `SELECT`, `UPDATE`, `INSERT`, and
`DELETE` permissions on all tables in the Guacamole database. These can
permissions can be easily granted in SQL Server using the `db_datawriter` and
`db_datareader` roles:

```console
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA
Password:
1> CREATE LOGIN guacamole_user WITH PASSWORD = 'some_password';
2> GO
1> USE guacamole_db;
2> GO
1> CREATE USER guacamole_user;
2> GO
1> ALTER ROLE db_datawriter ADD MEMBER guacamole_user;
2> ALTER ROLE db_datareader ADD MEMBER guacamole_user;
3> GO
1> quit
$
```

(sqlserver-auth-installation)=

Upgrading an existing Guacamole database
----------------------------------------

If you are upgrading from a version of Guacamole older than 1.6.0, you
may need to run one or more database schema upgrade scripts located within the
`sqlserver/schema/upgrade/` directory of [`guacamole-auth-jdbc-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz?action=download)
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

Installing/Enabling support for SQL Server
------------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:

1. You should have a copy of [`guacamole-auth-jdbc-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz?action=download) from
   earlier when you [created and initialized the database](sqlserver-auth-database-creation).

2. Create the `GUACAMOLE_HOME/extensions` and `GUACAMOLE_HOME/lib` directories,
   if they do not already exist.

3. Copy `sqlserver/guacamole-auth-jdbc-sqlserver-1.6.0.jar`
   within `GUACAMOLE_HOME/extensions`.

4. Copy the JDBC driver for your database to `GUACAMOLE_HOME/lib`. 
   Any of the following TDS-compatible JDBC drivers are supported for connecting
   Guacamole to SQL Server:

   * [Microsoft JDBC Driver for SQL Server](https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server)
   * [jTDS](http://jtds.sourceforge.net/)
   * [Progress DataDirect’s JDBC Driver for SQL Server](https://www.progress.com/jdbc/microsoft-sql-server)
   * Microsoft SQL Server 2000 JDBC Driver (legacy)

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
  `SQLSERVER_ENABLED` environment variable:

  ```yaml
  SQLSERVER_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e SQLSERVER_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `SQLSERVER_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `SQLSERVER_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::


(sqlserver-auth-configuration)=

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
sqlserver-database: guacamole_db
sqlserver-username: guacamole_user
sqlserver-password: some_password
```

The properties that must be set in all cases for any Guacamole installation
using this extension are:


`sqlserver-database`
: The name of the database that you created for Guacamole. This is given as
  "guacamole_db" in the examples given in this chapter.

`sqlserver-username`
: The username of the user that Guacamole should use to connect to the
  database.  This is given as "guacamole_user" in the examples given in this
  chapter.

`sqlserver-password`
: The password Guacamole should provide when authenticating with the database.
  This is given as "some_password" in the examples given in this chapter.
::::

::::{tab} Container (Docker)
If deploying Guacamole using Docker Compose, you will need to add a set of
environment variables to the `environment` section of your
`guacamole/guacamole` container that looks like the following:

```yaml
SQLSERVER_DATABASE: 'guacamole_db'
SQLSERVER_USERNAME: 'guacamole_user'
SQLSERVER_PASSWORD: 'some_password'
```

If instead deploying Guacamole by running `docker run` manually, these same
environment variables will need to be provided using the `-e` option.  For
example:

```console
$ docker run --name some-guacamole \
    -e SQLSERVER_DATABASE="guacamole_db" \
    -e SQLSERVER_USERNAME="guacamole_user" \
    -e SQLSERVER_PASSWORD="some_password" \
    -d -p 8080:8080 guacamole/guacamole
```

The environment variables that must be set in all cases for any Docker-based
Guacamole installation using this extension are:


`SQLSERVER_DATABASE`
: The name of the database that you created for Guacamole. This is given as
  "guacamole_db" in the examples given in this chapter.

`SQLSERVER_USERNAME`
: The username of the user that Guacamole should use to connect to the
  database.  This is given as "guacamole_user" in the examples given in this
  chapter.

`SQLSERVER_PASSWORD`
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


`sqlserver-hostname`
: The hostname or IP address of the server hosting your database. If not
  specified, "localhost" will be used by default.

`sqlserver-port`
: The port number of the SQL Server database to connect to. If not specified,
  the standard SQL Server port 1433 will be used.

`sqlserver-driver`
: The specific TDS-compatible JDBC driver to expect to have been installed.
  Multiple JDBC drivers are available that support SQL Server. If not using the
  Microsoft driver, this property must be specified to define the driver that
  will be used. Possible values are:
  
  microsoft2005
  : The current [Microsoft JDBC Driver for SQL Server](https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server),
    supporting SQL Server 2005 and later. This is the default.
  
  microsoft
  : The legacy Microsoft driver for SQL Server 2000.
  
  jtds
  : The open source [jTDS](http://jtds.sourceforge.net/) driver.
  
  datadirect
  : [Progress DataDirect’s JDBC Driver for SQL Server](https://www.progress.com/jdbc/microsoft-sql-server).

`sqlserver-instance`
: The instance name that the SQL Server driver should attempt to connect to, if
  not the default SQL Server instance. This instance name is configured during
  the SQL Server installation. This property is optional, and most installations
  should work without the need to specify an instance name.

`sqlserver-batch-size`
: Controls how many objects may be retrieved from the database in a single
  query. If more objects than this number are requested, retrieval of those
  objects will be automatically and transparently split across multiple
  queries.
  
  By default, SQL Server queries will retrieve no more than 500 objects.
::::

::::{tab} Container (Docker)


`SQLSERVER_HOSTNAME`
: The hostname or IP address of the server hosting your database. If not
  specified, "localhost" will be used by default.

`SQLSERVER_PORT`
: The port number of the SQL Server database to connect to. If not specified,
  the standard SQL Server port 1433 will be used.

`SQLSERVER_DRIVER`
: The specific TDS-compatible JDBC driver to expect to have been installed.
  Multiple JDBC drivers are available that support SQL Server. If not using the
  Microsoft driver, this property must be specified to define the driver that
  will be used. Possible values are:
  
  microsoft2005
  : The current [Microsoft JDBC Driver for SQL Server](https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server),
    supporting SQL Server 2005 and later. This is the default.
  
  microsoft
  : The legacy Microsoft driver for SQL Server 2000.
  
  jtds
  : The open source [jTDS](http://jtds.sourceforge.net/) driver.
  
  datadirect
  : [Progress DataDirect’s JDBC Driver for SQL Server](https://www.progress.com/jdbc/microsoft-sql-server).

`SQLSERVER_INSTANCE`
: The instance name that the SQL Server driver should attempt to connect to, if
  not the default SQL Server instance. This instance name is configured during
  the SQL Server installation. This property is optional, and most installations
  should work without the need to specify an instance name.

`SQLSERVER_BATCH_SIZE`
: Controls how many objects may be retrieved from the database in a single
  query. If more objects than this number are requested, retrieval of those
  objects will be automatically and transparently split across multiple
  queries.
  
  By default, SQL Server queries will retrieve no more than 500 objects.
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


`sqlserver-user-password-min-length`
: The minimum length required of all user passwords, in characters. By default,
  password length is not enforced.

`sqlserver-user-password-require-multiple-case`
: Whether all user passwords must have at least one lowercase character and one
  uppercase character. By default, no such restriction is imposed.

`sqlserver-user-password-require-symbol`
: Whether all user passwords must have at least one non-alphanumeric character
  (symbol). By default, no such restriction is imposed.

`sqlserver-user-password-require-digit`
: Whether all user passwords must have at least one numeric character (digit).
  By default, no such restriction is imposed.

`sqlserver-user-password-prohibit-username`
: Whether users are prohibited from including their own username in their
  password. By default, no such restriction is imposed.
::::

::::{tab} Container (Docker)


`SQLSERVER_USER_PASSWORD_MIN_LENGTH`
: The minimum length required of all user passwords, in characters. By default,
  password length is not enforced.

`SQLSERVER_USER_PASSWORD_REQUIRE_MULTIPLE_CASE`
: Whether all user passwords must have at least one lowercase character and one
  uppercase character. By default, no such restriction is imposed.

`SQLSERVER_USER_PASSWORD_REQUIRE_SYMBOL`
: Whether all user passwords must have at least one non-alphanumeric character
  (symbol). By default, no such restriction is imposed.

`SQLSERVER_USER_PASSWORD_REQUIRE_DIGIT`
: Whether all user passwords must have at least one numeric character (digit).
  By default, no such restriction is imposed.

`SQLSERVER_USER_PASSWORD_PROHIBIT_USERNAME`
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


`sqlserver-user-password-min-age`
: The minimum number of days which must elapse before a user may reset their
  password, where zero represents no limit. By default, no minimum number of
  days is required.

`sqlserver-user-password-max-age`
: The maximum number of days which may elapse before a user is automatically
  required to reset their password, where zero represents no limit. By default,
  users are not automatically required to reset their password based on
  password age.
::::

::::{tab} Container (Docker)


`SQLSERVER_USER_PASSWORD_MIN_AGE`
: The minimum number of days which must elapse before a user may reset their
  password, where zero represents no limit. By default, no minimum number of
  days is required.

`SQLSERVER_USER_PASSWORD_MAX_AGE`
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


`sqlserver-user-password-history-size`
: The number of previous passwords remembered for each user, where zero
  represents no history. If set to a non-zero value, users will be restricted
  from reusing any password in their password history. Passwords are remembered
  only in hashed and salted form. By default, previous passwords are not
  remembered and no such restriction is enforced.
::::

::::{tab} Container (Docker)


`SQLSERVER_USER_PASSWORD_HISTORY_SIZE`
: The number of previous passwords remembered for each user, where zero
  represents no history. If set to a non-zero value, users will be restricted
  from reusing any password in their password history. Passwords are remembered
  only in hashed and salted form. By default, previous passwords are not
  remembered and no such restriction is enforced.
::::

(sqlserver-auth-concurrency)=

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


`sqlserver-default-max-connections`
: The maximum number of concurrent connections to allow to any one connection,
  regardless of which user is accessing the connection, where zero denotes
  unlimited. By default, overall concurrent access to individual connections is
  not limited.

`sqlserver-default-max-group-connections`
: The maximum number of concurrent connections to allow to any one connection
  group, regardless of which user is accessing the connection group, where zero
  denotes unlimited. By default, overall concurrent access to individual
  connection groups is not limited.

`sqlserver-default-max-connections-per-user`
: The maximum number of concurrent connections to allow to any one connection
  by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to individual connections is not limited.

`sqlserver-default-max-group-connections-per-user`
: The maximum number of concurrent connections to allow to any one connection
  group by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to connection groups is limited to one user.

`sqlserver-absolute-max-connections`
: The maximum number of concurrent connections to allow overall, regardless of
  which connection or connection group is used and regardless of which user is
  accessing the connection/group, where zero denotes unlimited. By default,
  overall concurrent access to Guacamole is not limited.
::::

::::{tab} Container (Docker)


`SQLSERVER_DEFAULT_MAX_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one connection,
  regardless of which user is accessing the connection, where zero denotes
  unlimited. By default, overall concurrent access to individual connections is
  not limited.

`SQLSERVER_DEFAULT_MAX_GROUP_CONNECTIONS`
: The maximum number of concurrent connections to allow to any one connection
  group, regardless of which user is accessing the connection group, where zero
  denotes unlimited. By default, overall concurrent access to individual
  connection groups is not limited.

`SQLSERVER_DEFAULT_MAX_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow to any one connection
  by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to individual connections is not limited.

`SQLSERVER_DEFAULT_MAX_GROUP_CONNECTIONS_PER_USER`
: The maximum number of concurrent connections to allow to any one connection
  group by the same user, where zero denotes unlimited. By default, per-user
  concurrent access to connection groups is limited to one user.

`SQLSERVER_ABSOLUTE_MAX_CONNECTIONS`
: The maximum number of concurrent connections to allow overall, regardless of
  which connection or connection group is used and regardless of which user is
  accessing the connection/group, where zero denotes unlimited. By default,
  overall concurrent access to Guacamole is not limited.
::::

(sqlserver-auth-restrict)=

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


`sqlserver-user-required`
: Whether a user account within the database is required for authentication to
  succeed, even if the user has been authenticated via another extension. By
  default, successful authentication via any extension is sufficient, and
  database user accounts are not strictly required.

`sqlserver-auto-create-accounts`
: Whether to automatically create user accounts in the database for users who
  have successfully authenticate through another extension. Users that are
  automatically created are granted `READ` permission on their own user account
  and no other explicit permissions. By default users will not be automatically
  created.

`sqlserver-track-external-connection-history`
: Whether connection history records should be created for connections not
  defined in the database. By default, external connection history will be
  tracked unless this is explicitly disabled by setting this to "false".
::::

::::{tab} Container (Docker)


`SQLSERVER_USER_REQUIRED`
: Whether a user account within the database is required for authentication to
  succeed, even if the user has been authenticated via another extension. By
  default, successful authentication via any extension is sufficient, and
  database user accounts are not strictly required.

`SQLSERVER_AUTO_CREATE_ACCOUNTS`
: Whether to automatically create user accounts in the database for users who
  have successfully authenticate through another extension. Users that are
  automatically created are granted `READ` permission on their own user account
  and no other explicit permissions. By default users will not be automatically
  created.

`SQLSERVER_TRACK_EXTERNAL_CONNECTION_HISTORY`
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


`sqlserver-enforce-access-windows-for-active-sessions`
: Whether time-based access windows should be enforced for active user sessions.
  By default, users will be logged out when an access window closes, even if
  they are currently logged in. To allow logged-in users to continue to use the
  application after an access window closes, set this to "false". Users will
  always be prevented from logging in outside of access windows regardless of
  this setting.
::::

::::{tab} Container (Docker)


`SQLSERVER_ENFORCE_ACCESS_WINDOWS_FOR_ACTIVE_SESSIONS`
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

(sqlserver-auth-default-user)=

Logging in
----------

```{include} include/jdbc-default-user.md
```
