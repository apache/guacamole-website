Database authentication
=======================

:::{toctree}
:hidden:

MariaDB / MySQL <mysql-auth>
PostgreSQL <postgresql-auth>
SQL Server <sqlserver-auth>
:::

Guacamole supports providing authentication and storage leveraging any of the
following databases:

* [MariaDB or MySQL](mysql-auth)
* [PostgreSQL](postgresql-auth)
* [SQL Server](sqlserver-auth)

Using a database for authentication/storage is _highly recommended_ and
provides additional features, such as the ability to use load-balancing groups,
connection sharing links, and a convenient, web-based administrative interface.

Using a database alongside other authentication methods
-------------------------------------------------------

While most authentication extensions function independently, the database
authentication can act in a subordinate role, allowing users and user groups
from other authentication extensions to be associated with connections within
the database.

**Users and groups are considered identical to those within the database if they
have the same names** (with the nature of that comparison dictated by [the
application-wide case sensitivity setting](initial-setup)), and the
authentication result of another extension will be trusted if it succeeds. A
user with an account under multiple systems will thus be able to see data from
each system after successfully logging in.

:::{hint}
For more information on using the database authentication alongside other
mechanisms, see [](ldap-and-database) within [](ldap-auth).
:::

