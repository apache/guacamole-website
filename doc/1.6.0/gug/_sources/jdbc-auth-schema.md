(jdbc-auth-schema)=

Database schema reference
=========================

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

## Entities

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

## Users

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

### Password history

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

### Login history

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

## User groups

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

## Connections and parameters

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

### Usage history

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

## Sharing profiles and parameters

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

## Connection groups

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

## Permissions

There are several permissions tables in the schema which correspond to the
types of permissions in Guacamole's authentication model: system permissions,
which control operations that affect the system as a whole, and permissions
which control operations that affect specific objects within the system, such
as users, connections, or groups.

(jdbc-auth-schema-system-permissions)=

### System permissions

System permissions are defined by entries in the `guacamole_system_permission`
table. Each entry grants permission for a specific user or user group to
perform a specific system operation.

The `guacamole_system_permission` table contains the following columns:

`entity_id`
: The value of the `entity_id` column of the entry associated with the user 
  or user group owning this permission.

`permission`
: The permission being granted. This column can have one of seven possible 
  values:
  * `ADMINISTER`, which grants the ability to administer the entire 
  system (essentially a wildcard permission).
  * `AUDIT`, which allows a user to see login records and connection
    history across the entire system.
  * `CREATE_CONNECTION`, which grants the ability to create connections.
  * `CREATE_CONNECTION_GROUP`, which grants the ability to create connections
    groups.
  * `CREATE_SHARING_PROFILE`, which grants the ability to create sharing
    profiles.
  * `CREATE_USER`, which grants the ability to create users.
  * `CREATE_USER_GROUP`, which grants the ability to create user groups.

(jdbc-auth-schema-user-permissions)=

### User permissions

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

### User group permissions

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

### Connection permissions

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

### Sharing profile permissions

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

### Connection group permissions

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

