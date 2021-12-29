CAS Authentication
==================

CAS is an open-source Single Sign On (SSO) provider that allows multiple
applications and services to authenticate against it and brokers those
authentication requests to a back-end authentication provider. This module
allows Guacamole to redirect to CAS for authentication and user services. This
module must be layered on top of other authentication extensions that provide
connection information, as it only provides user authentication.

(cas-downloading)=

Downloading the CAS authentication extension
--------------------------------------------

```{include} include/sso-download.md
```

The extension for the desired SSO method, in this case
`guacamole-auth-sso-cas-1.4.0.jar` from within the `cas/` subdirectory, must
ultimately be placed in `GUACAMOLE_HOME/extensions`.

(installing-cas-auth)=

Installing CAS authentication
-----------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. *If you are unsure where
`GUACAMOLE_HOME` is located on your system, please consult
[](configuring-guacamole) before proceeding.*

To install the CAS authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-sso-cas-1.4.0.jar` within `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use CAS authentication, as described below.

(guac-cas-config)=

### Configuring Guacamole for CAS Authentication

Guacamole's CAS support requires specifying two properties that describe the
CAS authentication server and the Guacamole deployment. These properties are
*absolutely required in all cases*, as they dictate how Guacamole should
connect to the CAS and how CAS should redirect users back to Guacamole once
their identity has been confirmed:

`cas-authorization-endpoint`
: The URL of the CAS authentication server. This should be the full path to the
  base of the CAS installation.

`cas-redirect-uri`
: The URI to redirect back to upon successful authentication. Normally this
  will be the full URL of your Guacamole installation.

Additional optional properties are available to control how CAS tokens are
processed, including whether [CAS ClearPass](cas-clearpass) should be used and
how user group memberships should be derived:

`cas-clearpass-key`
: If using CAS ClearPass to pass the SSO password to Guacamole, this parameter
  specifies the private key file to use to decrypt the password. See [the section
  on ClearPass](cas-clearpass) below.

`cas-group-attribute`
: The CAS attribute that determines group membership, typically "memberOf".
  This parameter is only required if using CAS to define user group memberships.
  If omitted, groups aren't retrieved from CAS, and all other group-related
  properties for CAS are ignored.

`cas-group-format`
: The format that CAS will use for its group names. Possible values are
  `plain`, for groups that are simple text names, or `ldap`, for groups that are
  represented as LDAP DNs. If set to `ldap`, group names are always determined
  from the last (leftmost) attribute of the DN. If omitted, `plain` is used by
  default.

  This property has no effect if cas-group-attribute is not set.

`cas-group-ldap-base-dn`
: The base DN to require for LDAP-formatted CAS groups. If specified, only CAS
  groups beneath this DN will be included, and all other CAS groups will be
  ignored.

  This property has no effect if cas-group-format is not `ldap`.

`cas-group-ldap-attribute`
: The LDAP attribute to require for LDAP-formatted CAS groups. If specified,
  only CAS groups that use this attribute for the name of the group will be
  included. Note that LDAP group names are *always determined from the last
  (leftmost) attribute of the DN*. Specifying this property will only have the
  effect of ignoring any groups that do not use the specified attribute to
  represent the group name.

  This property has no effect if cas-group-format is not `ldap`.

(cas-login)=

### Controlling login behavior

```{include} include/sso-login-behavior.md
```

#### Automatically redirecting all unauthenticated users

To ensure users are redirected to the CAS identity provider immediately
(without a Guacamole login screen), ensure the CAS extension has priority over
all others:

```
extension-priority: cas
```

#### Presenting unauthenticated users with a login screen

To ensure users are given a normal Guacamole login screen and have the option
to log in with traditional credentials _or_ with CAS, ensure the CAS extension
does not have priority:

```
extension-priority: *, cas
```

(completing-cas-install)=

### Completing the installation

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before CAS authentication can be used. *Doing this will disconnect all active
users, so be sure that it is safe to do so prior to attempting installation.*
When ready, restart your servlet container and give the new authentication a
try.

(cas-clearpass)=

### Using CAS ClearPass

CAS has a function called ClearPass that can be used to cache the password used
for SSO authentication and make that available to services at a later time.
Configuring the CAS server for ClearPass is beyond the scope of this article -
more information can be found on the Apereo CAS wiki at the following URL:
<https://apereo.github.io/cas>.

Once you have CAS configured for credential caching, you need to configure the
service with a keypair for passing the credential securely. The public key gets
installed on the CAS server, while the private key gets configured with the
cas-clearpass-key property. The private key file needs to be in RSA PKCS8
format.

