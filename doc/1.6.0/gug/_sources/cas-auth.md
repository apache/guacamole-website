Using CAS for single sign-on
============================

CAS is an open-source Single Sign On (SSO) provider that allows multiple
applications and services to authenticate against it and brokers those
authentication requests to a back-end authentication provider. This module
allows Guacamole to redirect to CAS for authentication and user services. This
module must be layered on top of other authentication extensions that provide
connection information, as it only provides user authentication.

```{include} include/warn-config-changes.md
```

(cas-downloading)=

Installing/Enabling the CAS authentication extension
----------------------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:
1. Download [`guacamole-auth-sso-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-sso-1.6.0.tar.gz?action=download) from [the release page for
   Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
   and extract it.

2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

3. Copy the `cas/guacamole-auth-sso-cas-1.6.0.jar` file from the contents of the
   archive to `GUACAMOLE_HOME/extensions/`.

4. Proceed with the configuring Guacamole for the newly installed extension as
   described below. The extension will be loaded after Guacamole has been
   restarted.

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
  `CAS_ENABLED` environment variable:

  ```yaml
  CAS_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e CAS_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `CAS_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `CAS_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

Required configuration
----------------------

::::{tab} Native Webapp (Tomcat)

Guacamole's CAS support requires specifying two properties that
describe the CAS authentication server and the Guacamole deployment.
These properties are *absolutely required in all cases*, as they
dictate how Guacamole should connect to CAS and how CAS should redirect users
back to Guacamole once their identity has been confirmed.

If deploying Guacamole natively, you will need to add a section to your
`guacamole.properties` that looks like the following:

```ini
cas-authorization-endpoint: https://cas.example.net
cas-redirect-uri: https://guac.example.net
```

The properties that must be set in all cases for any Guacamole installation
using this extension are:


`cas-authorization-endpoint`
: The URL of the CAS authentication server. This should be the full path to the
  base of the CAS installation.

`cas-redirect-uri`
: The URI to redirect back to upon successful authentication. Normally this
  will be the full URL of your Guacamole installation.
::::

::::{tab} Container (Docker)

Guacamole's CAS support requires specifying two environment variables that
describe the CAS authentication server and the Guacamole deployment.
These environment variables are *absolutely required in all cases*, as they
dictate how Guacamole should connect to CAS and how CAS should redirect users
back to Guacamole once their identity has been confirmed.

If deploying Guacamole using Docker Compose, you will need to add a set of
environment variables to the `environment` section of your
`guacamole/guacamole` container that looks like the following:

```yaml
CAS_AUTHORIZATION_ENDPOINT: 'https://cas.example.net'
CAS_REDIRECT_URI: 'https://guac.example.net'
```

If instead deploying Guacamole by running `docker run` manually, these same
environment variables will need to be provided using the `-e` option.  For
example:

```console
$ docker run --name some-guacamole \
    -e CAS_AUTHORIZATION_ENDPOINT="https://cas.example.net" \
    -e CAS_REDIRECT_URI="https://guac.example.net" \
    -d -p 8080:8080 guacamole/guacamole
```

The environment variables that must be set in all cases for any Docker-based
Guacamole installation using this extension are:


`CAS_AUTHORIZATION_ENDPOINT`
: The URL of the CAS authentication server. This should be the full path to the
  base of the CAS installation.

`CAS_REDIRECT_URI`
: The URI to redirect back to upon successful authentication. Normally this
  will be the full URL of your Guacamole installation.
::::

Additional configuration (optional)
-----------------------------------

::::{tab} Native Webapp (Tomcat)

Additional optional properties are available to control how
CAS-related data is processed, including whether [CAS ClearPass](cas-clearpass)
should be used and how user group memberships should be derived:



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
::::

::::{tab} Container (Docker)

Additional optional environment variables are available to control how
CAS-related data is processed, including whether [CAS ClearPass](cas-clearpass)
should be used and how user group memberships should be derived:



`CAS_CLEARPASS_KEY`
: If using CAS ClearPass to pass the SSO password to Guacamole, this parameter
  specifies the private key file to use to decrypt the password. See [the section
  on ClearPass](cas-clearpass) below.

`CAS_GROUP_ATTRIBUTE`
: The CAS attribute that determines group membership, typically "memberOf".
  This parameter is only required if using CAS to define user group memberships.
  If omitted, groups aren't retrieved from CAS, and all other group-related
  properties for CAS are ignored.

`CAS_GROUP_FORMAT`
: The format that CAS will use for its group names. Possible values are
  `plain`, for groups that are simple text names, or `ldap`, for groups that are
  represented as LDAP DNs. If set to `ldap`, group names are always determined
  from the last (leftmost) attribute of the DN. If omitted, `plain` is used by
  default.
  
  This property has no effect if cas-group-attribute is not set.

`CAS_GROUP_LDAP_BASE_DN`
: The base DN to require for LDAP-formatted CAS groups. If specified, only CAS
  groups beneath this DN will be included, and all other CAS groups will be
  ignored.
  
  This property has no effect if cas-group-format is not `ldap`.

`CAS_GROUP_LDAP_ATTRIBUTE`
: The LDAP attribute to require for LDAP-formatted CAS groups. If specified,
  only CAS groups that use this attribute for the name of the group will be
  included. Note that LDAP group names are *always determined from the last
  (leftmost) attribute of the DN*. Specifying this property will only have the
  effect of ignoring any groups that do not use the specified attribute to
  represent the group name.
  
  This property has no effect if cas-group-format is not `ldap`.
::::

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

Completing installation
-----------------------

```{include} include/ext-completing.md
```

(cas-clearpass)=

Using CAS ClearPass
-------------------

CAS has a function called ClearPass that can be used to cache the password used
for SSO authentication and make that available to services at a later time.
Configuring the CAS server for ClearPass is beyond the scope of this article -
more information can be found on the Apereo CAS wiki at the following URL:
<https://apereo.github.io/cas>.

Once you have CAS configured for credential caching, you need to configure the
service with a keypair for passing the credential securely. The public key gets
installed on the CAS server, while the private key gets configured with the
`cas-clearpass-key property`. The private key file needs to be in RSA PKCS8
format.
