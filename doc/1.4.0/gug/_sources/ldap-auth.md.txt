LDAP authentication
===================

Guacamole supports LDAP authentication via an extension available from the main
project website. This extension allows users and connections to be stored
directly within an LDAP directory. If you have a centralized authentication
system that uses LDAP, Guacamole's LDAP support can be a good way to allow your
users to use their existing usernames and passwords to log into Guacamole.

To use the LDAP authentication extension, you will need:

1. An LDAP directory as storage for all authentication data, such as OpenLDAP.

2. The ability to modify the schema of your LDAP directory.

The instructions here assume you already have an LDAP directory installed and
working, and do not cover the initial setup of such a directory.

:::{important}
This chapter involves modifying the contents of `GUACAMOLE_HOME` - the
Guacamole configuration directory. If you are unsure where `GUACAMOLE_HOME` is
located on your system, please consult [](configuring-guacamole) before
proceeding.
:::

(ldap-architecture)=

How Guacamole uses LDAP
-----------------------

If the LDAP extension is installed, Guacamole will authenticate users against
your LDAP server by attempting a bind as that user. The given username and
password will be submitted to the LDAP server during the bind attempt.

If the bind attempt is successful, the set of available Guacamole connections
is queried from the LDAP directory by executing an LDAP query as the bound
user. Each Guacamole connection is represented within the directory as a
special type of group: `guacConfigGroup`.  Attributes associated with the group
define the protocol and parameters of the connection, and users are allowed
access to the connection only if they are associated with that group.

This architecture has a number of benefits:

1. Your users can use their existing usernames and passwords to log into
   Guacamole.

2. You can manage Guacamole connections using the same tool that you already
   use to manage your LDAP directory, such as [Apache Directory
   Studio](https://directory.apache.org/studio/).

3. Existing security restrictions can limit visibility/accessibility of
   Guacamole connections.

4. Access to connections can easily be granted and revoked, as each connection
   is represented by a group.

:::{important}
Though Guacamole connections can be stored within the LDAP directory, this is
not required. Connection data can alternatively be stored within a database
like MySQL or PostgreSQL as long as the LDAP username matches the username of
the database user. Configuring Guacamole to use a database for authentication
or connection storage is covered in [](jdbc-auth) and later in this chapter in
[](ldap-and-database).
:::

(ldap-downloading)=

Downloading the LDAP extension
------------------------------

The LDAP authentication extension is available separately from the main
`guacamole.war`. The link for this and all other officially-supported and
compatible extensions for a particular version of Guacamole are provided on the
release notes for that version. You can find the release notes for current
versions of Guacamole here: <http://guacamole.apache.org/releases/>.

The LDAP authentication extension is packaged as a `.tar.gz` file containing:

`guacamole-auth-ldap-1.4.0.jar`
: The Guacamole LDAP support extension itself, which must be placed in
  `GUACAMOLE_HOME/extensions`.

`schema/`
: LDAP schema files. An `.ldif` file compatible with OpenLDAP is provided, as
  well as a `.schema` file compliant with RFC-2252. The `.schema` file can be
  transformed into the `.ldif` file automatically.

(ldap-schema-changes)=

Preparing your LDAP directory (optional)
----------------------------------------

Although your LDAP directory already provides a means of storing and
authenticating users, Guacamole also needs storage of connection configuration
data, such as hostnames and ports, and a means of associating users with
connections that they should have access to. You can do this either through
modifying the LDAP directory schema, or through using a database like MySQL or
PostgreSQL. If you do not wish to use the LDAP directory for connection
storage, skip ahead to [](ldap-and-database).

If you wish to store connection data directly within the LDAP directory, the
required modifications to the LDAP schema are made through applying one of the
provided schema files. These schema files define an additional object class,
`guacConfigGroup`, which contains all configuration information for a
particular connection, and can be associated with arbitrarily-many users and
groups. Each connection defined by a `guacConfigGroup` will be accessible only
by users who are members of that group (specified with the member attribute),
or who are members of associated groups (specified with the `seeAlso`
attribute).

:::{important}
The instructions given for applying the Guacamole LDAP schema changes are
specific to OpenLDAP, but other LDAP implementations, including Active
Directory, will have their own methods for updating the schema.

If you are not using OpenLDAP, a standards-compliant schema file is provided
that can be used to update the schema of any LDAP directory supporting
RFC-2252. Please consult the documentation of your LDAP directory to determine
how such schema changes can be applied.
:::

The schema files are located within the `schema/` directory of the archive
containing the LDAP extension. You will only need one of these files:

`guacConfigGroup.schema`
: A standards-compliant file describing the schema. This file can be used with
  any LDAP directory compliant with RFC-2252.

`guacConfigGroup.ldif`
: An LDIF file compatible with OpenLDAP. This file was automatically built from
  the provided `.schema` file for convenience.

This chapter will cover applying `guacConfigGroup.ldif` to an OpenLDAP server.
If you are not using OpenLDAP, your LDAP server should provide documentation
for modifying its schema. If this is the case, please consult the documentation
of your LDAP server before proceeding.

### Applying the schema changes to OpenLDAP

Schema changes to OpenLDAP are applied using the {command}`ldapadd` utility
with the provided `guacConfigGroup.ldif` file:

```console
# ldapadd -Q -Y EXTERNAL -H ldapi:/// -f schema/guacConfigGroup.ldif
adding new entry "cn=guacConfigGroup,cn=schema,cn=config"

#
```

If the `guacConfigGroup` object was added successfully, you should see output
as above. You can confirm the presence of the new object class using
{command}`ldapsearch`:

```console
# ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn
dn: cn=schema,cn=config

dn: cn={0}core,cn=schema,cn=config

dn: cn={1}cosine,cn=schema,cn=config

dn: cn={2}nis,cn=schema,cn=config

dn: cn={3}inetorgperson,cn=schema,cn=config

dn: cn={4}guacConfigGroup,cn=schema,cn=config

#
```

(ldap-and-database)=

Associating LDAP with a database
--------------------------------

If you install both the LDAP authentication as well as support for a database
(following the instructions in [](jdbc-auth)), Guacamole will automatically
attempt to authenticate against both systems whenever a user attempts to log
in. In addition to any visible objects within the LDAP directory, that user
will have access to any data associated with their account in the database, as
well as any data associated with user groups that they belong to. LDAP user
accounts and groups will be considered equivalent to database users and groups
if their unique names are identical, as determined by the attributes given for
[the `ldap-username-attribute` and `ldap-group-name-attribute`
properties](guac-ldap-config).

Data can be manually associated with LDAP user accounts or groups by creating
corresponding users or groups within the database which each have the same
names. As long as the names are identical, a successful login attempt against
LDAP will be trusted by the database authentication, and that user's associated
data will be visible.

If an administrator account (such as the default `guacadmin` user provided with
the database authentication) has a corresponding user in the LDAP directory
with permission to read other LDAP users and groups, the Guacamole
administrative interface will include them in the lists presented to the
administrator, and will allow connections from the database to be associated
with those users or groups directly.

(installing-ldap-auth)=

Installing LDAP authentication
------------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. To install the LDAP authentication
extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-ldap-1.4.0.jar` within `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use LDAP authentication, as described below.

:::{important}
You will need to restart Guacamole by restarting your servlet container in
order to complete the installation. Doing this will disconnect all active
users, so be sure that it is safe to do so prior to attempting installation. If
you do not configure the LDAP authentication properly, Guacamole will not start
up again until the configuration is fixed.
:::

(guac-ldap-config)=

### Configuring Guacamole for LDAP

Additional properties may be added to `guacamole.properties` to describe how
your LDAP directory is organized and how Guacamole should connect (and bind) to
your LDAP server. Among these properties, only the ldap-user-base-dn property
is required:

`ldap-hostname`
: The hostname of your LDAP server. If omitted, "localhost" will be used by
  default. You will need to use a different value if your LDAP server is
  located elsewhere.

`ldap-port`
: The port your LDAP server listens on. If omitted, the standard LDAP or LDAPS
  port will be used, depending on the encryption method specified with
  `ldap-encryption-method` (if any). Unencrypted LDAP uses the standard port of
  389, while LDAPS uses port 636. Unless you manually configured your LDAP
  server to do otherwise, your LDAP server probably listens on port 389.

`ldap-encryption-method`
: The encryption mechanism that Guacamole should use when communicating with
  your LDAP server. Legal values are "none" for unencrypted LDAP, "ssl" for
  LDAP over SSL/TLS (commonly known as LDAPS), or "starttls" for STARTTLS. If
  omitted, encryption will not be used.

  If you do use encryption when connecting to your LDAP server, you will need
  to ensure that its certificate chain can be verified using the certificates
  in Java's trust store, often referred to as `cacerts`. If this is not the
  case, you will need to use Java's `keytool` utility to either add the
  necessary certificates or to create a new trust store containing those
  certificates.

  If you will be using your own trust store and not the default `cacerts`, you
  will need to specify the full path to that trust store using the system
  property `javax.net.ssl.trustStore`. Note that this is a system property and
  *not* a Guacamole property; it must be specified when starting the JVM using
  the `-D` option. Your servlet container will provide some means of specifying
  startup options for the JVM.

`ldap-max-search-results`
: The maximum number of search results that can be returned by a single LDAP
  query. LDAP queries which exceed this maximum will fail. *This property is
  optional.* If omitted, each LDAP query will be limited to a maximum of 1000
  results.

`ldap-search-bind-dn`
: The DN (Distinguished Name) of the user to bind as when authenticating users
  that are attempting to log in. If specified, Guacamole will query the LDAP
  directory to determine the DN of each user that logs in. If omitted, each
  user's DN will be derived directly using the base DN specified with
  `ldap-user-base-dn`.

`ldap-search-bind-password`
: The password to provide to the LDAP server when binding as
  `ldap-search-bind-dn` to authenticate other users. This property is only used
  if ldap-search-bind-dn is specified. If omitted, but `ldap-search-bind-dn` is
  specified, Guacamole will attempt to bind with the LDAP server without a
  password.

`ldap-user-base-dn`
: The base of the DN for all Guacamole users. *This property is absolutely
  required in all cases.* All Guacamole users must be descendents of this base
  DN.

  If a search DN is provided (via `ldap-search-bind-dn`), then Guacamole users
  need only be somewhere within the subtree of the specified user base DN.

  If a search DN *is not* provided, then all Guacamole users must be *direct
  descendents* of this base DN, as the base DN will be appended to the username
  to derive the user's DN. For example, if `ldap-user-base-dn` is
  "`ou=people,dc=example,dc=net`", and `ldap-username-attribute` is "uid", then
  a person attempting to login as "`user`" would be mapped to the following
  full DN: "`uid=user,ou=people,dc=example,dc=net`".

`ldap-username-attribute`
: The attribute or attributes which contain the username within all Guacamole
  user objects in the LDAP directory. Usually, and by default, this will simply
  be "uid". If your LDAP directory contains users whose usernames are dictated
  by different attributes, multiple attributes can be specified here, separated
  by commas, but beware: *doing so requires that a search DN be provided with
  `ldap-search-bind-dn`*.

  If a search DN *is not* provided, then the single username attribute
  specified here will be used together with the user base DN to directly derive
  the full DN of each user. For example, if `ldap-user-base-dn` is
  "`ou=people,dc=example,dc=net`", and `ldap-username-attribute` is "uid", then
  a person attempting to login as "`user`" would be mapped to the following
  full DN: "`uid=user,ou=people,dc=example,dc=net`".

`ldap-member-attribute`
: The attribute which contains the members within all group objects in the LDAP
  directory. Usually, and by default, this will simply be "member". If your
  LDAP directory contains groups whose members are dictated by a different
  attribute, it can be specified here.

`ldap-member-attribute-type`
: Specify whether the attribute defined in `ldap-member-attribute` (Usually
  "member") identifies a group member by DN or by usercode.  Possible values:
  "dn" (the default, if not specified) or "uid".

  Example: an LDAP server may present groups using the `groupOfNames`
  scheme:

  ```
  dn: cn=group1,ou=Groups,dc=example,dc=net
  objectClass: groupOfNames
  cn: group1
  gidNumber: 12345
  member: user1,ou=People,dc=example,dc=net
  member: user2,ou=People,dc=example,dc=net
  ```

  `ldap-member-attribute` is `member` and `ldap-member-attribute-type` is `dn`.

  Example: an LDAP server may present groups using the `posixGroup`
  scheme:

  ```
  dn: cn=group1,ou=Groups,dc=example,dc=net
  objectClass: posixGroup
  cn: group1
  gidNumber: 12345
  memberUid: user1
  memberUid: user2
  ```

  `ldap-member-attribute` is `memberUid` and `ldap-member-attribute-type` is
  `uid`

`ldap-user-attributes`
: The attribute or attributes to retrieve from the LDAP directory for the
  currently logged-in user, separated by commas. If specified, the attributes
  listed here are retrieved from each authenticated user and dynamically
  applied to the parameters of that user's connections as [parameter
  tokens](parameter-tokens) with the prefix "`LDAP_`".

  When a user authenticates with LDAP and accesses a particular Guacamole
  connection, the values of these tokens will be the values of their
  corresponding attributes at the time of authentication. If the attribute has
  no value for the current user, then the corresponding token is not applied.
  If the attribute has multiple values, then the first value of the attribute
  is used.

  When converting an LDAP attribute name into a parameter token name, the name
  of the attribute is transformed into uppercase with each word separated by
  underscores, a naming convention referred to as "uppercase with underscores"
  or "[screaming snake case](https://en.wikipedia.org/wiki/Naming_convention_(programming)#Multiple-word_identifiers)".

  For example:

  | LDAP Attribute                     | Parameter Token                                |
  | ---------------------------------- | ---------------------------------------------- |
  | `lowercase-with-dashes`            | `${LDAP_LOWERCASE_WITH_DASHES}`                |
  | `CamelCase`                        | `${LDAP_CAMEL_CASE}`                           |
  | `headlessCamelCase`                | `${LDAP_HEADLESS_CAMEL_CASE}`                  |
  | `lettersAndNumbers1234`            | `${LDAP_LETTERS_AND_NUMBERS_1234}`             |
  | `aRANDOM_mixOf-3NAMINGConventions` | `${LDAP_A_RANDOM_MIX_OF_3_NAMING_CONVENTIONS}` |

  Usage of parameter tokens is discussed in more detail in
  [](configuring-guacamole) in [](parameter-tokens).

`ldap-user-search-filter`
: The search filter used to query the LDAP tree for users that can log into and
  be granted privileges in Guacamole. *If this property is omitted the default of
  `(objectClass=*)` will be used.*

`ldap-config-base-dn`
: The base of the DN for all Guacamole configurations. *This property is
  optional.* If omitted, the configurations of Guacamole connections will
  simply not be queried from the LDAP directory. If specified, this base DN
  will be used when querying the configurations accessible by a user once they
  have successfully logged in.

  Each configuration is analogous to a connection. Within Guacamole's LDAP
  support, each configuration functions as a group, having user members (via
  the `member` attribute) and optionally group members (via the `seeAlso`
  attribute), where each member of a particular configuration group will have
  access to the connection defined by that configuration.

`ldap-group-base-dn`
: The base of the DN for all user groups that may be used by other extensions
  to define permissions or that may referenced within Guacamole configurations
  using the standard seeAlso attribute. All groups which will be used to
  control access to Guacamole configurations must be descendents of this base
  DN. *If this property is omitted, the `seeAlso` attribute will have no effect
  on Guacamole configurations.*

`ldap-group-name-attribute`
: The attribute or attributes which define the unique name of user groups in
  the LDAP directory. Usually, and by default, this will simply be "cn". If
  your LDAP directory contains groups whose names are dictated by different
  attributes, multiple attributes can be specified here, separated by commas.

`ldap-group-search-filter`
: The search filter used to query the LDAP tree for groups that may be used by
  other extensions to define permissions. *If this property is omitted the
  default of `(objectClass=*)` will be used.*

`ldap-dereference-aliases`
: Controls whether or not the LDAP connection follows (dereferences) aliases as
  it searches the tree. Possible values for this property are "never" (the
  default) so that aliases will never be followed, "searching" to dereference
  during search operations after the base object is located, "finding" to
  dereference in order to locate the search base, but not during the actual
  search, and "always" to always dereference aliases.

`ldap-follow-referrals`
: This option controls whether or not the LDAP module follow referrals when
  processing search results from a LDAP search. Referrals can be pointers to
  other parts of an LDAP tree, or to a different server/connection altogether.
  This is a boolean parameter, with valid options of "true" or "false." The
  default is false. When disabled, LDAP referrals will be ignored when
  encountered by the Guacamole LDAP client and the client will move on to the
  next result.  When enabled, the LDAP client will follow the referral and
  process results within the referral, subject to the maximum hops parameter
  below.

`ldap-max-referral-hops`
: This option controls the maximum number of referrals that will be processed
  before the LDAP client refuses to follow any more referrals. The default is
  5. If the `ldap-follow-referrals` property is set to false (the default),
  this option has no effect. If the `ldap-follow-referrals` option is set
  to true, this will limit the depth of referrals followed to the number
  specified.

`ldap-operation-timeout`
: This option sets the timeout, in seconds, of any single LDAP operation. The
  default is 30 seconds. When this timeout is reached LDAP operations will be
  aborted.

Again, even if the defaults are sufficient for the other properties, *you must
still specify the `ldap-user-base-dn` property*. An absolutely minimal
configuration for LDAP authentication will look like the following:

```
# LDAP properties
ldap-user-base-dn: ou=people,dc=example,dc=net
```

### Completing the installation

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before the LDAP authentication will take effect. Restart your servlet container
and give the new authentication a try.

:::{important}
You only need to restart your servlet container. *You do not need to restart
guacd*.

guacd is completely independent of the web application and does not deal with
`guacamole.properties` or the authentication system in any way. Since you are
already restarting the servlet container, restarting guacd as well technically
won't hurt anything, but doing so is completely pointless.
:::

If Guacamole does not come back online after restarting your servlet container,
check the logs. Problems in the configuration of the LDAP extension will
prevent Guacamole from starting up, and any such errors will be recorded in the
logs of your servlet container. If properly configured, you will be able to log
in as any user within the defined ldap-user-base-dn.

(ldap-auth-schema)=

The LDAP schema
---------------

Guacamole's LDAP support allows users and connections to be managed purely
within an LDAP directory defined in `guacamole.properties`.  This is
accomplished with a minimum of changes to the standard LDAP schema - all
Guacamole users are traditional LDAP users and share the same mechanism of
authentication. The only new type of object required is a representation for
Guacamole connections, `guacConfigGroup`, which was added to your server's
schema during the install process above.

### Users

All Guacamole users, as far as the LDAP support is concerned, are LDAP users
with standard LDAP credentials. When a user signs in to Guacamole, their
username and password will be used to bind to the LDAP server. If this bind
operation is successful, the available connections are queried from the
directory and the user is allowed in.

### Connections and parameters

Each connection is represented by an instance of the `guacConfigGroup` object
class, an extended version of the standard LDAP `groupOfNames`, which provides
a protocol and set of parameters. Only members of the `guacConfigGroup` will
have access to the corresponding connection.

The `guacConfigGroup` object class provides two new attributes in addition to
those provided by `groupOfNames`:

`guacConfigProtocol`
: The protocol associated with the connection, such as "`vnc`" or "`rdp`". This
  attribute is required for every `guacConfigGroup` and can be given only once.

`guacConfigParameter`
: The name and value of a parameter for the specified protocol. This is given
  as `name=value`, where "name" is the name of the parameter, as defined by the
  documentation for the protocol specified, and "value" is any allowed value for
  that parameter.

  This attribute can be given multiple times for the same connection.

For example, to create a new VNC connection which connects to "localhost" at
port 5900, while granting access to `user1` and `user2`, you could create an
`.ldif` file like the following:

```
dn: cn=Example Connection,ou=groups,dc=example,dc=net
objectClass: guacConfigGroup
objectClass: groupOfNames
cn: Example Connection
guacConfigProtocol: vnc
guacConfigParameter: hostname=localhost
guacConfigParameter: port=5900
guacConfigParameter: password=secret
member: cn=user1,ou=people,dc=example,dc=net
member: cn=user2,ou=people,dc=example,dc=net
```

The new connection can then be created using the {command}`ldapadd` utility:

```console
$ ldapadd -x -D cn=admin,dc=example,dc=net -W -f example-connection.ldif
Enter LDAP Password:
adding new entry "cn=Example Connection,ou=groups,dc=example,dc=net"

$
```

Where `cn=admin,dc=example,dc=net` is an administrator account with permission
to create new entries, and `example-connection.ldif` is the name of the `.ldif`
file you just created.

There is, of course, no need to use only the standard LDAP utilities to create
connections and users. There are useful graphical environments for manipulating
LDAP directories, such as [Apache Directory Studio](https://directory.apache.org/studio/),
which make many of the tasks given above much easier.

