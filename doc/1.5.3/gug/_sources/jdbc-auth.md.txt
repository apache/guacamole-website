Database authentication
=======================

Guacamole supports authentication via MySQL, PostgreSQL, or SQL Server
databases through extensions available from the project website. Using a
database for authentication provides additional features, such as the ability
to use load balancing groups of connections and a web-based administrative
interface. Unlike the default, XML-driven authentication module, all changes to
users and connections take effect immediately; users need not logout and back
in to see new connections.

While most authentication extensions function independently, the database
authentication can act in a subordinate role, allowing users and user groups
from other authentication extensions to be associated with connections within
the database. Users and groups are considered identical to those within the
database if they have the same names, and the authentication result of another
extension will be trusted if it succeeds. A user with an account under multiple
systems will thus be able to see data from each system after successfully
logging in. For more information on using the database authentication alongside
other mechanisms, see [](ldap-and-database) within [](ldap-auth).

To use the database authentication extension, you will need:

1. A supported database - currently MariaDB, MySQL, PostgreSQL, or SQL Server.

2. Sufficient permission to create new databases, to create new users, and to
   grant those users permissions.

3. Network access to the database from the Guacamole server.

:::{important}
This chapter involves modifying the contents of `GUACAMOLE_HOME` - the
Guacamole configuration directory. If you are unsure where `GUACAMOLE_HOME` is
located on your system, please consult [](configuring-guacamole) before
proceeding.
:::

Downloading the database authentication extension
-------------------------------------------------

The database authentication extension is available separately from the main
`guacamole.war`. The link for this and all other officially-supported and
compatible extensions for a particular version of Guacamole are provided on the
release notes for that version. You can find the release notes for current
versions of Guacamole here: <http://guacamole.apache.org/releases/>.

The database authentication extension is packaged as a `.tar.gz` file
containing several database-specific directories. Only one of the directories
within the archive will be applicable to you, depending on whether you are
using MariaDB, MySQL, PostgreSQL, or SQL Server.

Each database-specific directory contains a `schema/` directory and `.jar` file
(the actual Guacamole extension). The Guacamole extension `.jar` will
ultimately need to be placed within `GUACAMOLE_HOME/extensions`, while the JDBC
driver must be downloaded separately from the database vendor and placed within
`GUACAMOLE_HOME/lib`.

::::{tab} MySQL
:::{list-table}
:stub-columns: 1
* - Guacamole extension
  - `mysql/guacamole-auth-jdbc-mysql-1.5.3.jar`
* - SQL schema scripts
  - `mysql/schema/`
* - JDBC driver
  - *See below*
:::

Any of the following MySQL-compatible JDBC drivers are supported for connecting Guacamole with MySQL or MariaDB:

* [MySQL Connector/J](http://dev.mysql.com/downloads/connector/j/)
* [MariaDB Connector/J](https://mariadb.com/kb/en/about-mariadb-connector-j/)

If using the JDBC driver from MySQL, the required `.jar` will be within a
`.tar.gz` archive.
::::

::::{tab} PostgreSQL
:::{list-table}
:stub-columns: 1
* - Guacamole extension
  - `postgresql/guacamole-auth-jdbc-postgresql-1.5.3.jar`
* - SQL schema scripts
  - `postgresql/schema/`
* - JDBC driver
  - [PostgreSQL JDBC Driver](https://jdbc.postgresql.org/download/#latest-versions)
:::
::::

::::{tab} SQL Server
:::{list-table}
:stub-columns: 1
* - Guacamole extension
  - `sqlserver/guacamole-auth-jdbc-sqlserver-1.5.3.jar`
* - SQL schema scripts
  - `sqlserver/schema/`
* - JDBC driver
  - *See below*
:::

Any of the following TDS-compatible JDBC drivers are supported for connecting
Guacamole to SQL Server:

* [Microsoft JDBC Driver for SQL Server](https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server)
* [jTDS](http://jtds.sourceforge.net/)
* [Progress DataDirect’s JDBC Driver for SQL Server](https://www.progress.com/jdbc/microsoft-sql-server)
* Microsoft SQL Server 2000 JDBC Driver (legacy)
::::

(jdbc-auth-database-creation)=

Creating the Guacamole database
-------------------------------

The database authentication module will need a database to store
authentication data and a user to use only for data access and
manipulation. You can use an existing database and existing user, but
for the sake of simplicity and security, these instructions assume you
will be creating a new database and new user that will be used only by
Guacamole and only for this authentication module.

You need MariaDB, MySQL, PostgreSQL, or SQL Server installed, and must
have sufficient access to create and administer databases. If this is
not the case, install your database of choice now. Most distributions
will provide a convenient MySQL or PostgreSQL package which will set up
everything for you, including the root database user, if applicable. If
you're using SQL Server, you need to install the packages on your
platform of choice, and also make sure that you obtain the proper
licensing for the version and edition of SQL Server you are running.

For the sake of clarity, these instructions will refer to the database
as "guacamole_db", but the database can be named whatever you like.

:::{tab} MySQL
```console
$ mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 233
Server version: 5.5.29-0ubuntu0.12.10.1 (Ubuntu)

Copyright (c) 2000, 2012, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE DATABASE guacamole_db;
Query OK, 1 row affected (0.00 sec)

mysql> quit
Bye
$ ls schema/
001-create-schema.sql  002-create-admin-user.sql  upgrade
$ cat schema/*.sql | mysql -u root -p guacamole_db
Enter password:
$
```
:::

:::{tab} PostgreSQL
```console
$ createdb guacamole_db
$ ls schema/
001-create-schema.sql  002-create-admin-user.sql
$ cat schema/*.sql | psql -d guacamole_db -f -
CREATE TYPE
CREATE TYPE
CREATE TYPE
CREATE TABLE
CREATE INDEX
...
INSERT 0 1
INSERT 0 4
INSERT 0 3
$
```
:::

:::{tab} SQL Server
```console
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA
Password:
1> CREATE DATABASE guacamole_db;
2> GO
1> quit
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
:::

Granting Guacamole access to the database
-----------------------------------------

For Guacamole to be able to execute queries against the database, you must
create a new user for the database and grant that user sufficient privileges to
manage the contents of all tables in the database. The user created for
Guacamole needs only `SELECT`, `UPDATE`, `INSERT`, and `DELETE` permissions on
all Guacamole tables.  Additionally, if using PostgreSQL, the user will need
`SELECT` and `USAGE` permission on all sequences within all Guacamole tables.
*No other permissions should be granted.*

These instructions will refer to the user as "guacamole_user" but the user can
be named whatever you like. Naturally, you should also choose a real password
for your user rather than the string "some_password" used as a placeholder
below.

:::{tab} MySQL
```console
$ mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 233
Server version: 5.5.29-0ubuntu0.12.10.1 (Ubuntu)

Copyright (c) 2000, 2012, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE USER 'guacamole_user'@'localhost' IDENTIFIED BY 'some_password';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.02 sec)

mysql> quit
Bye
$
```
:::

:::{tab} PostgreSQL
```console
$ psql -d guacamole_db
psql (9.3.6)
Type "help" for help.

guacamole=# CREATE USER guacamole_user WITH PASSWORD 'some_password';
CREATE ROLE
guacamole=# GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;
GRANT
guacamole=# GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;
GRANT
guacamole=# \q
$
```
:::

:::{tab} SQL Server
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
:::

(jdbc-auth-installation)=

Upgrading an existing Guacamole database
----------------------------------------

If you are upgrading from an older version of Guacamole, you may need to run
one or more database schema upgrade scripts located within the
`schema/upgrade/` directory. Each of these scripts is named
{samp}`upgrade-pre-{VERSION}.sql` where `VERSION` is the version of Guacamole
where those changes were introduced. They need to be run when you are upgrading
from a version of Guacamole older than `VERSION`.

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

:::{important}
Because the permissions granted to the Guacamole-specific PostgreSQL user when
the database was first created will not automatically be granted for any new
tables and sequences, you will also need to re-grant those permissions after
applying any upgrade relevant scripts:

```
$ psql -d guacamole_db
psql (9.3.6)
Type "help" for help.

guacamole=# GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;
GRANT
guacamole=# GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;
GRANT
guacamole=# \q
$
```
:::

Installing database authentication
----------------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. To install the database
authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` and `GUACAMOLE_HOME/lib` directories,
   if they do not already exist.

2. Copy `guacamole-auth-jdbc-mysql-1.5.3.jar` *or*
   `guacamole-auth-jdbc-postgresql-1.5.3.jar` *or*
   `guacamole-auth-jdbc-sqlserver-1.5.3.jar` within
   `GUACAMOLE_HOME/extensions`, depending on whether you are using
   MySQL/MariaDB, PostgreSQL, or SQL Server.

3. Copy the JDBC driver for your database to `GUACAMOLE_HOME/lib`. Without a
   JDBC driver for your database, Guacamole will not be able to connect and
   authenticate users.

4. Configure Guacamole to use database authentication, as described below.

:::{important}
You will need to restart Guacamole by restarting your servlet container in
order to complete the installation. Doing this will disconnect all active
users, so be sure that it is safe to do so prior to attempting installation. If
you do not configure the database authentication properly, Guacamole will not
start up again until the configuration is fixed.
:::

(jdbc-auth-configuration)=

### Configuring Guacamole for database authentication

Additional properties must be added to `guacamole.properties` for Guacamole to
properly connect to your database. These properties are specific to the
database being used, and must be set correctly for authentication to work.

The properties absolutely required by the database authentication extension are
relatively few and self-explanatory, describing only how the connection to the
database is to be established, and how Guacamole will authenticate when
querying the database:

:::{tab} MySQL
`mysql-hostname`
: The hostname or IP address of the server hosting your database.

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
:::

:::{tab} PostgreSQL
`postgresql-hostname`
: The hostname or IP address of the server hosting your database.

`postgresql-database`
: The name of the database that you created for Guacamole. This is given as
  "guacamole_db" in the examples given in this chapter.

`postgresql-username`
: The username of the user that Guacamole should use to connect to the
  database.  This is given as "guacamole_user" in the examples given in this
  chapter.

`postgresql-password`
: The password Guacamole should provide when authenticating with the database.
  This is given as "some_password" in the examples given in this chapter.
:::

:::{tab} SQL Server
`sqlserver-hostname`
: The hostname or IP address of the server hosting your database.

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
:::

A minimal `guacamole.properties` configured to connect to a locally-hosted
database would look like the following:

:::{tab} MySQL
```
# MySQL properties
mysql-hostname: localhost
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: some_password
```
:::

:::{tab} PostgreSQL
```
# PostgreSQL properties
postgresql-hostname: localhost
postgresql-database: guacamole_db
postgresql-username: guacamole_user
postgresql-password: some_password
```
:::

:::{tab} SQL Server
```
# SQL Server properties
sqlserver-hostname: localhost
sqlserver-database: guacamole_db
sqlserver-username: guacamole_user
sqlserver-password: some_password
```
:::

:::{important}
Be sure to specify the correct username and password for the database user you
created, and to specify the correct database. Authentication will not work if
these parameters are not correct.
:::

Additional optional properties are available to control how Guacamole connects
to the database server:

:::{tab} MySQL
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
  : Well-known TimeZone Identifiers, in the Region/Locale format. Examples are:

    ```
    mysql-server-timezone: America/Los_Angeles
    mysql-server-timezone: Africa/Johannesburg
    mysql-server-timezone: China/Shanghai
    ```

   GMT+/-HH:MM
   : GMT or custom timezones specified by GMT offset. Examples of valid GMT
     specifications are:

     ```
     mysql-server-timezone: GMT
     mysql-server-timezone: GMT-00:00
     mysql-server-timezone: GMT+0000
     mysql-server-timezone: GMT-0
     ```

     Examples of custom timezones specified by GMT offsets are:

     ```
     mysql-server-timezone: GMT+0130
     mysql-server-timezone: GMT-0430
     mysql-server-timezone: GMT+06:00
     mysql-server-timezone: GMT-9
     ```

   The MySQL Driver implements several parameters specific to
   configuring SSL for secure connections to MySQL servers that support
   or require encrypted communications. *Older versions of MySQL
   Connector/J have known issues with SSL verification - if you
   experience problems connecting to SSL-secured MySQL databases it is
   recommended that you update to a current version of the driver.*

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
:::

:::{tab} PostgreSQL
`postgresql-port`
: The port number of the PostgreSQL database to connect to. If not specified,
  the standard PostgreSQL port 5432 will be used.

`postgresql-ssl-mode`
: This property sets the SSL mode that the JDBC extension will attempt to use
  when communicating with the remote Postgres server. The values for this
  property match the standard values supported by the Postgres JDBC driver:

  disable
  : Do not use SSL, and fail if the server requires it.

  allow
  : If the server requires encryption use it, otherwise prefer unencrypted
    connections.

  prefer
  : Try SSL connections, first, but allow unencrypted connections if the server
    does not support SSL or if SSL negotiations fail. This is the
    default.

  require
  : Require SSL connections, but implicitly trust all server certificates and
    authorities.

  verify-ca
  : Require SSL connections, and verify that the server certificate is issued
    by a known certificate authority.

  verify-full
  : Require SSL connections, verifying that the server certificate is issued
    by a known authority, and that the name on the certificate matches the name of
    the server.

`postgresql-ssl-cert-file`
: The file containing the client certificate to be used when making an
  SSL-encrtyped connection to the Postgres server, in PEM format. This property
  is optional, and will be ignored if the SSL mode is set to disable.

`postgresql-ssl-key-file`
: The file containing the client private key to be used when making an
  SSL-encrypted connection to the Postgres server, in PEM format. This property
  is optional, and will be ignored if the SSL mode is set to disable.

`postgresql-ssl-root-cert-file`
: The file containing the root and intermedidate certificates against which the
  server certificate will be verified when making an SSL-encrypted connection to
  the Postgres server. This file should contain one or more PEM-formatted
  authority certificates. This property is optional, and will only be used if SSL
  mode is set to verify-ca or verify-full.

  If SSL is set to one of the verification modes and this property is not
  specified, the JDBC driver will attempt to use the `.postgresql/root.crt`
  file from the home directory of the user running the web application server
  (e.g. Tomcat). If this property is not specified and the default file does
  not exist, the Postgres JDBC driver will fail to connect to the server.

`postgresql-ssl-key-password`
: The password that will be used to access the client private key file, if the
  client private key is encrypted. This property is optional, and is only used if
  the `postgresql-ssl-key-file` property is set and SSL is enabled.

`postgresql-default-statement-timeout`
: The number of seconds the driver will wait for a response from the database,
  before aborting the query. A value of 0 (the default) means the timeout is
  disabled.

`postgresql-socket-timeout`
: The number of seconds to wait for socket read operations. If reading from the
  server takes longer than this value, the connection will be closed. This can
  be used to handle network problems such as a dropped connection to the
  database. Similar to `postgresql-default-statement-timeout`, it will also
  abort queries that take too long. A value of 0 (the default) means the
  timeout is disabled.

`postgresql-batch-size`
: Controls how many objects may be retrieved from the database in a single
  query. If more objects than this number are requested, retrieval of those
  objects will be automatically and transparently split across multiple
  queries.

  By default, PostgreSQL queries will retrieve no more than 5000 objects.
:::

:::{tab} SQL Server
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
:::

#### Enforcing password policies

Configuration options are available for enforcing rules intended to encourage
password complexity and regular changing of passwords. None of these options
are enabled by default, but can be selectively enabled through additional
properties in `guacamole.properties`.

##### Password complexity

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

:::{tab} MySQL
```
mysql-user-password-min-length: 8
mysql-user-password-require-multiple-case: true
mysql-user-password-require-symbol: true
mysql-user-password-require-digit: true
mysql-user-password-prohibit-username: true
```
:::

:::{tab} PostgreSQL
```
postgresql-user-password-min-length: 8
postgresql-user-password-require-multiple-case: true
postgresql-user-password-require-symbol: true
postgresql-user-password-require-digit: true
postgresql-user-password-prohibit-username: true
```
:::

:::{tab} SQL Server
```
sqlserver-user-password-min-length: 8
sqlserver-user-password-require-multiple-case: true
sqlserver-user-password-require-symbol: true
sqlserver-user-password-require-digit: true
sqlserver-user-password-prohibit-username: true
```
:::

##### Password age / expiration

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
using a pair of properties, each accepting values given in units of days:

:::{tab} MySQL
```
mysql-user-password-min-age: 7
mysql-user-password-max-age: 90
```
:::

:::{tab} PostgreSQL
```
postgresql-user-password-min-age: 7
postgresql-user-password-max-age: 90
```
:::

:::{tab} SQL Server
```
sqlserver-user-password-min-age: 7
sqlserver-user-password-max-age: 90
```
:::

:::{important}
So that administrators can always intervene in the case that a password needs
to be reset despite restrictions, the minimum age restriction does not apply to
any user with permission to administer the system.
:::

##### Preventing password reuse

If desired, Guacamole can keep track of each user's most recently used
passwords, and will prohibit reuse of those passwords until the password has
been changed sufficiently many times. By default, Guacamole will not keep track
of old passwords.

Note that these passwords are hashed in the same manner as each user's current
password. When a user's password is changed, the hash, salt, etc. currently
stored for that user is actually just copied verbatim (along with a timestamp)
into a list of historical passwords, with older entries from this list being
automatically deleted.

:::{tab} MySQL
```
mysql-user-password-history-size: 6
```
:::

:::{tab} PostgreSQL
```
postgresql-user-password-history-size: 6
```
:::

:::{tab} SQL Server
```
sqlserver-user-password-history-size: 6
```
:::

(jdbc-auth-concurrency)=

#### Concurrent use of Guacamole connections

The database authentication module provides configuration options to restrict
concurrent use of connections or connection groups. These options are set
through `guacamole.properties` and specify the default concurrency policies for
connections and connection groups. The values set through the properties can be
overridden later on a per-connection basis using the administrative interface:

:::{tab} MySQL
```
mysql-default-max-connections: 1
mysql-default-max-group-connections: 1
```
:::

:::{tab} PostgreSQL
```
postgresql-default-max-connections: 1
postgresql-default-max-group-connections: 1
```
:::

:::{tab} SQL Server
```
sqlserver-default-max-connections: 1
sqlserver-default-max-group-connections: 1
```
:::

These properties are not required, but with the above properties in place,
users attempting to use a connection or group that is already in use will be
denied access. By default, concurrent access is allowed.

Concurrent access can also be restricted such that a particular user may only
use a connection or group a certain number of times. By default, per-user
concurrent use is limited for connection groups (to avoid allowing a single
user to exhaust the contents of the group) but otherwise unrestricted. This
default behavior can be modified through `guacamole.properties` or the
per-connection settings exposed in the administrative interface:

:::{tab} MySQL
```
mysql-default-max-connections-per-user: 0
mysql-default-max-group-connections-per-user: 0
```
:::

:::{tab} PostgreSQL
```
postgresql-default-max-connections-per-user: 0
postgresql-default-max-group-connections-per-user: 0
```
:::

:::{tab} SQL Server
```
sqlserver-default-max-connections-per-user: 0
sqlserver-default-max-group-connections-per-user: 0
```
:::

If you wish to impose an absolute limit on the number of connections that can
be established through Guacamole, ignoring which users or connections are
involved, this can be done as well. By default, Guacamole will impose no such
limit:

:::{tab} MySQL
```
mysql-absolute-max-connections: 0
```
:::

:::{tab} PostgreSQL
```
postgresql-absolute-max-connections: 0
```
:::

:::{tab} SQL Server
```
sqlserver-absolute-max-connections: 0
```
:::

(jdbc-auth-restrict)=

### Restricting authentication to database users only

By default, users will be allowed access to Guacamole as long as they are
authenticated by at least one extension. If database authentication is in use,
and a user is not associated with the database, then that user will be allowed
access to Guacamole if another extension grants this access, and will be
provided with a view of the data exposed by other extensions for that user
account.

In some situations, such as when [combining LDAP with a
database](ldap-and-database), it would be preferable to let the database have
the last word regarding whether a user should be allowed into the system:
restricting access to only those users which exist in the database, and
explicitly denying authentication through all other means unless that user has
been associated with the database as well.  This behavior can be forced by
setting properties which declare that database user accounts are required:

:::{tab} MySQL
```
mysql-user-required: true
```
:::

:::{tab} PostgreSQL
```
postgresql-user-required: true
```
:::

:::{tab} SQL Server
```
sqlserver-user-required: true
```
:::

With the above properties set, successful authentication attempts for users
which are not associated with the database will be vetoed by the database
authentication. Guacamole will report that the login is invalid, as if the user
does not exist at all.

(jdbc-auth-auto-create)=

### Auto-creating database users

Guacamole supports the ability to layer authentication modules on top of one
another such that users successfully authenticated from one extension (e.g.
LDAP) can be assigned permissions to connections in another extension (e.g.
JDBC). Other extensions, like the TOTP extension, rely on the database
extension to be able to store information for various user accounts. In these
situations it can be difficult to have to manually create user accounts within
the database extension.

The database extension provides a mechanism for enabling auto-creation of user
accounts that successfully authenticate from other extensions.  This
functionality is disabled by default, but can be enabled in each of the
supported database extensions by enabling the appropriate option in
`guacamole.properties`. The resulting accounts will only have `READ` access to
themselves until additional permissions are granted, either explicitly by the
administrator or by permissions assigned to groups of which the user is a
member.

:::{tab} MySQL
```
mysql-auto-create-accounts: true
```
:::

:::{tab} PostgreSQL
```
postgresql-auto-create-accounts: true
```
:::

:::{tab} SQL Server
```
sqlserver-auto-create-accounts: true
```
:::

### Completing the installation

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before the database authentication will take effect. Restart your servlet
container and give the new authentication a try.

:::{important}
You only need to restart your servlet container. *You do not need to restart
guacd*.

guacd is completely independent of the web application and does not deal with
`guacamole.properties` or the authentication system in any way. Since you are
already restarting the servlet container, restarting guacd as well technically
won't hurt anything, but doing so is completely pointless.
:::

If Guacamole does not come back online after restarting your servlet container,
check the logs. Problems in the configuration of the database authentication
extension will prevent Guacamole from starting up, and any such errors will be
recorded in the logs of your servlet container.

(jdbc-auth-default-user)=

Logging in
----------

The default Guacamole user created by the provided SQL scripts is
"`guacadmin`", with a default password of "`guacadmin`". Once you have verified
that the database authentication is working, *you should change your password
immediately*.

More detailed instructions for managing users and connections is given in
[](administration).

(jdbc-auth-schema)=

Modifying data manually
-----------------------

If necessary, it is possible to modify the data backing the authentication
module manually by executing SQL statements against the database. In general
use, this will not be common, but if you need to bulk-insert a large number of
users or connections, or you wish to translate an existing configuration
automatically, you will need to know how everything is laid out at a high
level.

This section assumes knowledge of SQL and your chosen database, and that
whatever you need to do can be accomplished if only you had high-level
information about Guacamole's SQL schema.

(jdbc-auth-schema-entities)=

### Entities

Every user and user group has a corresponding entry in the `guacamole_entity`
table which serves as the basis for assignment of a unique name, permissions,
as well as relations which are common to both users and groups like group
membership. Each entity has a corresponding name which is unique across all
other entities of the same type.

If deleting a user or user group, the corresponding entity should also be
deleted. As any user or group which points to the entity will be deleted
automatically when the entity is deleted through cascading deletion, *it is
advisable to use the entity as the basis for any delete operation*.

The `guacamole_entity` table contains the following columns:

`entity_id`
: The unique integer associated with each entity (user or user group). This
  value is generated automatically when a new entry is inserted into the
  `guacamole_entity` table and is distinct from the unique integer associated
  with the user entry in [`guacamole_user`](jdbc-auth-schema-users) or the user
  group entry in [`guacamole_user_group`](jdbc-auth-schema-groups).

`name`
: The unique name associated with each user or group. This value must be
  specified manually, and must be different from any existing user or group in
  the table. The name need only be unique relative to the names of other entities
  having the same type (a user may have the same name as a group).

`type`
: The type of this entity. This can be either `USER` or `USER_GROUP`.

(jdbc-auth-schema-users)=

### Users

Every user has a corresponding entry in the `guacamole_user` and
[`guacamole_entity`](jdbc-auth-schema-entities) tables. Each user has a
corresponding unique username, specified via `guacamole_entity`, and salted
password. The salted password is split into two columns: one containing the
salt, and the other containing the password hashed with SHA-256.

If deleting a user, the [corresponding entity](jdbc-auth-schema-entities)
should also be deleted. As any user which points to the entity will be deleted
automatically when the entity is deleted through cascading deletion, *it is
advisable to use the entity as the basis for any delete operation*.

The `guacamole_user` table contains the following columns:

`user_id`
: The unique integer associated with each user. This value is generated
  automatically when a new entry is inserted into the `guacamole_user` table.

`entity_id`
: The value of the `entity_id` column of the `guacamole_entity` entry
  representing this user.

`password_hash`
: The result of hashing the user's password concatenated with the contents of
  `password_salt` using SHA-256. The salt is appended to the password prior to
  hashing.

  Although passwords set through Guacamole will always be salted, it is
  possible to use unsalted password hashes when inserted manually or through an
  external system. If `password_salt` is `NULL`, the `password_hash` will be
  handled as a simple unsalted hash of the password.

`password_salt`
: A 32-byte random value. When a new user is created from the web interface,
  this value is randomly generated using a cryptographically-secure random
  number generator.

  This will always be set for users whose passwords are set through Guacamole,
  but it is possible to use unsalted password hashes when inserted manually or
  through an external system. If `password_salt` is `NULL`, the `password_hash`
  will be handled as a simple unsalted hash of the password.

`password_date`
: The date (and time) that the password was last changed. When a password is
  changed via the Guacamole interface, this value is updated. This, along with
  the contents of the `guacamole_user_password_history` table, is used to
  enforce password policies.

`disabled`
: Whether login attempts as this user account should be rejected. If this
  column is set to `TRUE` or `1`, login attempts by this user will be rejected
  as if the user did not exist. By default, user accounts are not disabled, and
  login attempts will succeed if the user provides the correct password.

`expired`
: If set to `TRUE` or `1`, requires that the user reset their password prior to
  fully logging in. The user will be presented with a password reset form, and
  will not be allowed to log into Guacamole until the password has been changed.
  By default, user accounts are not expired, and no password reset will be
  required upon login.

`access_window_start`
: The time of day (not date) after which this user account may be used.  If
  `NULL`, this restriction does not apply. If set to non-`NULL`, attempts to log
  in after the specified time will be allowed, while attempts to log in before
  the specified time will be denied.

`access_window_end`
: The time of day (not date) after which this user account may *not* be used.
  If `NULL`, this restriction does not apply. If set to non-`NULL`, attempts to
  log in after the specified time will be denied, while attempts to log in
  before the specified time will be allowed.

`valid_from`
: The date (not time of day) after which this user account may be used.  If
  `NULL`, this restriction does not apply. If set to non-`NULL`, attempts to
  log in after the specified date will be allowed, while attempts to log in
  before the specified date will be denied.

`valid_until`
: The date (not time of day) after which this user account may *not* be used.
  If `NULL`, this restriction does not apply. If set to non-`NULL`, attempts to
  log in after the specified date will be denied, while attempts to log in
  before the specified date will be allowed.

`timezone`
: The time zone to use when interpreting the `access_window_start`,
  `access_window_end`, `valid_from`, and `valid_until` values. This value may
  be any Java `TimeZone` ID, as defined by
  [`getAvailableIDs()`](http://docs.oracle.com/javase/7/docs/api/java/util/TimeZone.html#getAvailableIDs())
  though the Guacamole management interface will only present a subset of these
  time zones.

`full_name`
: The user's full name. Unlike the username, this name need not be unique; it
  is optional and is meant for display purposes only.  Defining this value has
  no bearing on user identity, which is dictated purely by the username. User
  accounts with no associated full name should have this column set to `NULL`.

`email_address`
: The user's email address, if any. This value is optional, need not be unique
  relative to other defined users, and is meant for display purposes only.
  Defining this value has no bearing on user identity, which is dictated purely
  by the username. If the user has no associated email address, this column
  should be set to `NULL`.

`organization`
: The name of the organization, company, etc. that the user is affiliated with.
  This value is optional and is meant for display purposes only. Defining this
  value has no bearing on user identity, which is dictated purely by the
  username. Users with no associated organization should have this column set
  to `NULL`.

`organizational_role`
: The role or title of the user at the organization described by the
  organization column. This value is optional and is used for display purposes
  only. Defining this value has no bearing on user identity, which is dictated
  purely by the username. Users with no associated organization (or specific
  role/title at that organization) should have this column set to `NULL`.

:::{important}
If you choose to manually set unsalted password hashes, please be sure you
understand the security implications of doing so.

In the event that your database is compromised, finding the password for a
*salted* hash is computationally infeasible, but finding the password for an
*unsalted* hash is often not. In many cases, the password which corresponds to
an unsalted hash can be found simply by entering the hash into a search engine
like Google.
:::

If creating a user manually, the main complication is the salt, which must be
determined before the `INSERT` statement can be constructed, but this can be
dealt with using variables. For MySQL:

```mysql
-- Generate salt
SET @salt = UNHEX(SHA2(UUID(), 256));

-- Create base entity entry for user
INSERT INTO guacamole_entity (name, type)
VALUES ('myuser', 'USER');

-- Create user and hash password with salt
INSERT INTO guacamole_user (
    entity_id,
    password_salt,
    password_hash,
    password_date
)
SELECT
    entity_id,
    @salt,
    UNHEX(SHA2(CONCAT('mypassword', HEX(@salt)), 256)),
    CURRENT_TIMESTAMP
FROM guacamole_entity
WHERE
    name = 'myuser'
    AND type = 'USER';
```

This sort of statement is useful for both creating new users or for changing
passwords, especially if all administrators have forgotten theirs.

If you are not using MySQL, or you are using a version of MySQL that lacks the
SHA2 function, you will need to calculate the SHA-256 value manually (by using
the `sha256sum` command, for example).

(jdbc-auth-schema-password-history)=

#### Password history

When a user's password is changed, a copy of the previous password's
hash and salt is made within the `guacamole_user_password_history`.
Each entry in this table is associated with the user whose password
changed, along with the date that password first applied.

Old entries within this table are automatically deleted on a per-user
basis depending on the requirements of the password policy. For example,
if the password policy has been configured to require that users not
reuse any of their previous six passwords, then there will be no more
than six entries in this table for each user.

`password_history_id`
: The unique integer associated with each password history record. This 
  value is generated automatically when a new entry is inserted into the 
  `guacamole_user_password_history` table.

`user_id`
: The value of the `user_id` column from the entry in `guacamole_user`  
  associated with the user who previously had this password.

`password_hash`
: The hashed password specified within the `password_hash` column of  
  `guacamole_user` prior to the password being changed.

  In most cases, this will be a salted hash, though it is possible to force 
  the use of unsalted hashes when making changes to the database manually or
  through an external system.

`password_salt`
: The salt value specified within the `password_salt` column of 
  `guacamole_user` prior to the password being changed.

  This will always be set for users whose passwords are set through 
  Guacamole, but it is possible to use unsalted password hashes when 
  inserted manually or through an external system, in which case this may be
  `NULL`.

`password_date`
: The date (and time) that the password was set. The time that the password 
  ceased being used is recorded either by the `password_date` of the next 
  related entry in `guacamole_user_password_history` or `password_date` of 
  `guacamole_user` (if there is no such history entry).

(jdbc-auth-schema-login-history)=

#### Login history

When a user logs in or out, a corresponding entry in the
`guacamole_user_history` table is created or updated respectively.
Each entry is associated with the user that logged in and the time their
session began. If the user has logged out, the time their session ended
is also stored.

It is very unlikely that a user will need to update this table, but
knowing the structure is potentially useful if you wish to generate a
report of Guacamole usage. The `guacamole_user_history` table has the
following columns:

`history_id`
: The unique integer associated with each history record. This value is 
  generated automatically when a new entry is inserted into the 
  `guacamole_user_history` table.

`user_id`
: The value of the `user_id` from the entry in `guacamole_user` associated 
  with the user that logged in. If the user no longer exists, this will be 
  `NULL`.

`username`
: The username associated with the user at the time that they logged in. 
  This username value is not guaranteed to uniquely identify a user, as the 
  original user may be subsequently renamed or deleted.

`remote_host`
: The hostname or IP address of the machine that the user logged in from, if
  known. If unknown, this will be `NULL`.

`start_date`
: The time at which the user logged in. Despite its name, this column also 
  stores time information in addition to the date.

`end_date`
: The time at which the user logged out. If the user is still active, the 
  value in this column will be `NULL`. Despite its name, this column also 
  stores time information in addition to the date.

(jdbc-auth-schema-groups)=

### User groups

Similar to [users](jdbc-auth-schema-users), every user group has a
corresponding entry in the `guacamole_user_group` and
[`guacamole_entity`](jdbc-auth-schema-entities) tables. Each user group has a
corresponding unique name specified via `guacamole_entity`.

If deleting a user group, the [corresponding entity](jdbc-auth-schema-entities)
should also be deleted. As any user group which points to the entity will be
deleted automatically when the entity is deleted through cascading deletion,
*it is advisable to use the entity as the basis for any delete operation*.

The `guacamole_user_group` table contains the following columns:

`user_group_id`
: The unique integer associated with each user group. This value is 
  generated automatically when a new entry is inserted into the 
  `guacamole_user_group` table.

`entity_id`
: The value of the `entity_id` column of the `guacamole_entity` entry  
  representing this user group.

`disabled`
: Whether membership within this group should be taken into account when 
  determining the permissions granted to a particular user. If this column 
  is set to `TRUE` or `1`, membership in this group will have no effect on 
  user permissions, whether those permissions are granted to this group 
  directly or indirectly through the groups that this group is a member of. 
  By default, user groups are not disabled, and permissions granted to a 
  user through the group will be taken into account.

Membership within a user group is dictated through entries in the
`guacamole_user_group_member` table. As both users and user groups may be
members of groups, each entry associates the containing group with the entity
of the member.

The `guacamole_user_group_member` table contains the following columns:

`user_group_id`
: The `user_group_id` value of the user group having the specified member.

`member_entity_id`
: The `entity_id` value of the user or user group that is a member of the 
  specified group.

(jdbc-auth-schema-connections)=

### Connections and parameters

Each connection has an entry in the `guacamole_connection` table, with a
one-to-many relationship to parameters, stored as name/value pairs in the
`guacamole_connection_parameter` table.

The `guacamole_connection` table is simply a pairing of a unique and
descriptive name with the protocol to be used for the connection. It contains
the following columns:

`connection_id`
: The unique integer associated with each connection. This value is 
  generated automatically when a new entry is inserted into the 
  `guacamole_connection` table.

`connection_name`
: The unique name associated with each connection. This value must be 
  specified manually, and must be different from any existing connection 
  name in the same connection group. References to connections in other 
  tables use the value from `connection_id`, not `connection_name`.

`protocol`
: The protocol to use with this connection. This is the name of the protocol
  that should be sent to guacd when connecting, for example "`vnc`" or 
  "`rdp`".

`parent_id`
: The unique integer associated with the connection group containing this 
  connection, or `NULL` if this connection is within the root group.

`max_connections`
: The maximum number of concurrent connections to allow to this connection 
  at any one time *regardless of user*. `NULL` will use the default value 
  specified in `guacamole.properties` and a value of `0` denotes unlimited.

`max_connections_per_user`
: The maximum number of concurrent connections to allow to this connection  
  at any one time *from a single user*. `NULL` will use the default value  
  specified in `guacamole.properties` and a value of `0` denotes unlimited.

`proxy_hostname`
: The hostname or IP address of the Guacamole proxy daemon (guacd) which 
  should be used for this connection. If `NULL`, the value defined with the 
  `guacd-hostname` property in `guacamole.properties` will be used.

`proxy_port`
: The TCP port number of the Guacamole proxy daemon (guacd) which should be 
  used for this connection. If `NULL`, the value defined with the 
  `guacd-port` property in `guacamole.properties` will be used.

`proxy_encryption_method`
: The encryption method which should be used when communicating with the 
  Guacamole proxy daemon (guacd) for this connection. This can be either 
  `NONE`, for no encryption, or `SSL`, for SSL/TLS. If `NULL`, the 
  encryption method will be dictated by the `guacd-ssl` property in 
  `guacamole.properties`.

`connection_weight`
: The weight for a connection, used for applying weighted load balancing 
  algorithms when connections are part of a `BALANCING` group. This is an 
  integer value, where values `1` or greater will weight the connection 
  relative to other connections in that group, and values below `1` cause 
  the connection to be disabled in the group. If `NULL`, the connection will
  be assigned a default weight of `1`.

`failover_only`
: Whether this connection should be used for failover situations only, also 
  known as a "hot spare". If this column is set to `TRUE` or `1`, this 
  connection will be used only when another connection within the same 
  `BALANCING` connection group has failed due to an error within the remote 
  desktop.

  *Connection groups will always transparently switch to the next available 
  connection in the event of remote desktop failure, regardless of the value
  of this column.* This column simply dictates whether a particular 
  connection should be *reserved* for such situations, and left unused 
  otherwise.

  This column only has an effect on connections within `BALANCING` groups.

As there are potentially multiple parameters per connection, where the names of
each parameter are completely arbitrary and determined only by the protocol in
use, every parameter for a given connection has an entry in table
`guacamole_connection_parameter` table associated with its corresponding
connection. This table contains the following columns:

`connection_id`
: The `connection_id` value from the connection this parameter is for.

`parameter_name`
: The name of the parameter to set. This is the name listed in the 
  documentation for the protocol specified in the associated connection.

`parameter_value`
: The value to assign to the parameter named. While this value is an 
  arbitrary string, it must conform to the requirements of the protocol as 
  documented for the connection to be successful.

Adding a connection and corresponding parameters is relatively easy compared to
adding a user as there is no salt to generate nor password to hash:

```mysql
-- Create connection
INSERT INTO guacamole_connection (connection_name, protocol) VALUES ('test', 'vnc');

-- Determine the connection_id
SELECT * FROM guacamole_connection WHERE connection_name = 'test' AND parent_id IS NULL;

-- Add parameters to the new connection
INSERT INTO guacamole_connection_parameter VALUES (1, 'hostname', 'localhost');
INSERT INTO guacamole_connection_parameter VALUES (1, 'port', '5901');
```

(jdbc-auth-schema-connection-history)=

#### Usage history

When a connection is initiated or terminated, a corresponding entry in the
`guacamole_connection_history` table is created or updated respectively. Each
entry is associated with the user using the connection, the connection itself,
the [sharing profile](jdbc-auth-schema-sharing-profiles) in use (if the
connection is being shared), and the time the connection started. If the
connection has ended, the end time is also stored.

It is very unlikely that a user will need to update this table, but knowing the
structure is potentially useful if you wish to generate a report of Guacamole
usage. The `guacamole_connection_history` table has the following columns:

`history_id`
: The unique integer associated with each history record. This value is 
  generated automatically when a new entry is inserted into the 
  `guacamole_connection_history` table.

`user_id`
: The value of the `user_id` from the entry in `guacamole_user` associated 
  with the user using the connection. If the user no longer exists, this 
  will be `NULL`.

`username`
: The username associated with the user at the time that they used the 
  connection. This username value is not guaranteed to uniquely identify a 
  user, as the original user may be subsequently renamed or deleted.

`connection_id`
: The value of the `connection_id` from the entry in `guacamole_connection` 
  associated the connection being used. If the connection associated with 
  the history record no longer exists, this will be `NULL`.

`connection_name`
: The name associated with the connection at the time that it was used.

`sharing_profile_id`
: The value of the `sharing_profile_id` from the entry in 
  `guacamole_sharing_profile` associated the sharing profile being used to 
  access the connection. If the connection is not being shared (no sharing 
  profile is being used), or if the sharing profile associated with the 
  history record no longer exists, this will be `NULL`.

`sharing_profile_name`
: The name associated with the sharing profile being used to access the 
  connection at the time this history entry was recorded. If the connection 
  is not being shared, this will be `NULL`.

`start_date`
: The time at which the connection was started by the user specified. 
  Despite its name, this column also stores time information in addition to 
  the date.

`end_date`
: The time at which the connection ended. If the connection is still active,
  the value in this column will be `NULL`. Despite its name, this column 
  also stores time information in addition to the date.

(jdbc-auth-schema-sharing-profiles)=

### Sharing profiles and parameters

Each sharing profile has an entry in the `guacamole_sharing_profile` table,
with a one-to-many relationship to parameters, stored as name/value pairs in
the `guacamole_sharing_profile_parameter` table.

The `guacamole_sharing_profile` table is simply a pairing of a unique and
descriptive name with the connection that can be shared using the sharing
profile, also known as the "primary connection". It contains the following
columns:

`sharing_profile_id`
: The unique integer associated with each sharing profile. This value is 
  generated automatically when a new entry is inserted into the 
  `guacamole_sharing_profile` table.

`sharing_profile_name`
: The unique name associated with each sharing profile. This value must be 
  specified manually, and must be different from any existing sharing 
  profile name associated with the same primary connection. References to 
  sharing profiles in other tables use the value from `sharing_profile_id`, 
  not `sharing_profile_name`.

`primary_connection_id`
: The unique integer associated with the primary connection. The "primary 
  connection" is the connection which can be shared using this sharing 
  profile.

As there are potentially multiple parameters per sharing profile, where the
names of each parameter are completely arbitrary and determined only by the
protocol associated with the primary connection, every parameter for a given
sharing profile has an entry in the `guacamole_sharing_profile_parameter` table
associated with its corresponding sharing profile. This table contains the
following columns:

`sharing_profile_id`
: The `sharing_profile_id` value from the entry in the 
  `guacamole_sharing_profile` table for the sharing profile this parameter 
  applies to.

`parameter_name`
: The name of the parameter to set. This is the name listed in the 
  documentation for the protocol of the primary connection of the associated
  sharing profile.

`parameter_value`
: The value to assign to the parameter named. While this value is an 
  arbitrary string, it must conform to the requirements of the protocol as 
  documented.

(jdbc-auth-schema-connection-groups)=

### Connection groups

Each connection group has an entry in the `guacamole_connection_group` table,
with a one-to-many relationship to other groups and connections.

The `guacamole_connection_group` table is simply a pairing of a unique and
descriptive name with a group type, which can be either `ORGANIZATIONAL` or
`BALANCING`. It contains the following columns:

`connection_group_id`
: The unique integer associated with each connection group. This value is 
  generated automatically when a new entry is inserted into the 
  `guacamole_connection_group` table.

`connection_group_name`
: The unique name associated with each connection group. This value must be 
  specified manually, and must be different from any existing connection 
  group name in the same connection group. References to connections in 
  other tables use the value from `connection_group_id`, not 
  `connection_group_name`.

`type`
: The type of this connection group. This can be either `ORGANIZATIONAL` or 
  `BALANCING`.

`parent_id`
: The unique integer associated with the connection group containing this 
  connection group, or `NULL` if this connection group is within the root 
  group.

`max_connections`
: The maximum number of concurrent connections to allow to this connection 
  group at any one time *regardless of user*. `NULL` will use the default 
  value specified in `guacamole.properties` and a value of `0` denotes 
  unlimited. This only has an effect on `BALANCING` groups.

`max_connections_per_user`
: The maximum number of concurrent connections to allow to this connection 
  group at any one time *from a single user*. `NULL` will use the default 
  value specified in `guacamole.properties` and a value of `0` denotes 
  unlimited. This only has an effect on `BALANCING` groups.

`enable_session_affinity`
: Whether session affinity should apply to this connection group. If this 
  column is set to `TRUE` or `1`, users will be consistently routed to the 
  same underlying connection until they log out. The normal balancing 
  behavior will only apply for each user's first connection attempt during 
  any one Guacamole session. By default, session affinity is not enabled, 
  and connections will always be balanced across the entire connection 
  group. This only has an effect on `BALANCING` groups.

Adding a connection group is even simpler than adding a new connection as there
are no associated parameters stored in a separate table:

```mysql
-- Create connection group
INSERT INTO guacamole_connection_group (connection_group_name, type)
     VALUES ('test', 'ORGANIZATIONAL');
```

(jdbc-auth-schema-permissions)=

### Permissions

There are several permissions tables in the schema which correspond to the
types of permissions in Guacamole's authentication model: system permissions,
which control operations that affect the system as a whole, and permissions
which control operations that affect specific objects within the system, such
as users, connections, or groups.

(jdbc-auth-schema-system-permissions)=

#### System permissions

System permissions are defined by entries in the `guacamole_system_permission`
table. Each entry grants permission for a specific user or user group to
perform a specific system operation.

The `guacamole_system_permission` table contains the following columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`permission`
: The permission being granted. This column can have one of six possible 
  values: `ADMINISTER`, which grants the ability to administer the entire 
  system (essentially a wildcard permission), `CREATE_CONNECTION`, which 
  grants the ability to create connections, `CREATE_CONNECTION_GROUP`, which
  grants the ability to create connections groups, `CREATE_SHARING_PROFILE`,
  which grants the ability to create sharing profiles, `CREATE_USER`, which 
  grants the ability to create users, or `CREATE_USER_GROUP`, which grants 
  the ability to create user groups.

(jdbc-auth-schema-user-permissions)=

#### User permissions

User permissions are defined by entries in the `guacamole_user_permission`
table. Each entry grants permission for a specific user or user group to
perform a specific operation on an existing user.

The `guacamole_user_permission` table contains the following columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`affected_user_id`
: The value of the `user_id` column of the entry associated with the user 
  *affected* by this permission. This is the user that would be the object 
  of the operation represented by this permission.

`permission`
: The permission being granted. This column can have one of four possible 
  values: `ADMINISTER`, which grants the ability to add or remove 
  permissions which affect the user, `READ`, which grants the ability to 
  read data associated with the user, `UPDATE`, which grants the ability to 
  update data associated with the user, or `DELETE`, which grants the 
  ability to delete the user.

(jdbc-auth-schema-group-permissions)=

#### User group permissions

User group permissions are defined by entries in the
`guacamole_user_group_permission` table. Each entry grants permission for a
specific user or user group to perform a specific operation on an existing user
group.

The `guacamole_user_group_permission` table contains the following columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`affected_user_group_id`
: The value of the `user_group_id` column of the entry associated with the 
  user group *affected* by this permission. This is the user group that 
  would be the object of the operation represented by this permission.

`permission`
: The permission being granted. This column can have one of four possible 
  values: `ADMINISTER`, which grants the ability to add or remove 
  permissions which affect the user group, `READ`, which grants the ability 
  to read data associated with the user group, `UPDATE`, which grants the 
  ability to update data associated with the user group, or `DELETE`, which 
  grants the ability to delete the user group.

(jdbc-auth-schema-connection-permissions)=

#### Connection permissions

Connection permissions are defined by entries in the
`guacamole_connection_permission` table. Each entry grants permission for a
specific user or user group to perform a specific operation on an existing
connection.

The `guacamole_connection_permission` table contains the following columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`connection_id`
: The value of the `connection_id` column of the entry associated with the 
  connection affected by this permission. This is the connection that would 
  be the object of the operation represented by this permission.

`permission`
: The permission being granted. This column can have one of four possible 
  values: `ADMINISTER`, which grants the ability to add or remove 
  permissions which affect the connection, `READ`, which grants the ability 
  to read data associated with the connection (a prerequisite for 
  connecting), `UPDATE`, which grants the ability to update data associated 
  with the connection, or `DELETE`, which grants the ability to delete the 
  connection.

(jdbc-auth-schema-sharing-profile-permissions)=

#### Sharing profile permissions

Sharing profile permissions are defined by entries in the
`guacamole_sharing_profile_permission` table. Each entry grants permission for
a specific user or user group to perform a specific operation on an existing
sharing profile.

The `guacamole_sharing_profile_permission` table contains the following
columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`sharing_profile_id`
: The value of the `sharing_profile_id` column of the entry associated with 
  the sharing profile affected by this permission. This is the sharing 
  profile that would be the object of the operation represented by this 
  permission.

`permission`
: The permission being granted. This column can have one of four possible 
  values: `ADMINISTER`, which grants the ability to add or remove 
  permissions which affect the sharing profile, `READ`, which grants the 
  ability to read data associated with the sharing profile (a prerequisite 
  for using the sharing profile to share an active connection), `UPDATE`, 
  which grants the ability to update data associated with the sharing 
  profile, or `DELETE`, which grants the ability to delete the sharing 
  profile.

(jdbc-auth-schema-connection-group-permissions)=

#### Connection group permissions

Connection group permissions are defined by entries in the
`guacamole_connection_group_permission` table. Each entry grants permission for
a specific user or user group to perform a specific operation on an existing
connection group.

The `guacamole_connection_group_permission` table contains the following
columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`connection_group_id`
: The value of the `connection_group_id` column of the entry associated with
  the connection group affected by this permission. This is the connection 
  group that would be the object of the operation represented by this 
  permission.

`permission`
: The permission being granted. This column can have one of four possible 
  values: `ADMINISTER`, which grants the ability to add or remove 
  permissions which affect the connection group, `READ`, which grants the 
  ability to read data associated with the connection group, `UPDATE`, which
  grants the ability to update data associated with the connection group, or
  `DELETE`, which grants the ability to delete the connection group (and 
  implicitly its contents).

