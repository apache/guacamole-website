SAML Authentication
===================

SAML is a widely implemented and used Single Sign On (SSO) provider that allows
applications and services to authenticate in a standard way, and brokers those
authentication requests to one or more back-end authentication providers. The
SAML authentication extension allows Guacamole to redirect to a SAML Identity
Provider (IdP) for authentication and user services. This module does not
provide any capability for storing or retrieving connections, and must be
layered with other authentication extensions that provide connection
management.

(saml-downloading)=

Downloading the SAML authentication extension
---------------------------------------------

```{include} include/sso-download.md
```

The extension for the desired SSO method, in this case
`guacamole-auth-sso-saml-1.4.0.jar` from within the `saml/` subdirectory,
must ultimately be placed in `GUACAMOLE_HOME/extensions`.

(installing-saml-auth)=

Installing SAML authentication
------------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. *If you are unsure where
`GUACAMOLE_HOME` is located on your system, please consult
[](configuring-guacamole) before proceeding.*

To install the SAML authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-sso-saml-1.4.0.jar` within `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use SAML authentication, as described below.

(guac-saml-config)=

### Configuring Guacamole for SAML Authentication

The SAML authentication extension provides several configuration properties to
set it up to talk to the IdP. The SAML IdP also must be configured with
Guacamole as a Service Provider (SP). Configuration of the SAML IdP is beyond
the scope of this document, and will vary widely based on the IdP in use.

`saml-idp-metadata-url`
: The URI of the XML metadata file that from the SAML Identity Provider that
  contains all of the information the SAML extension needs in order to know how
  to authenticate with the IdP. This URI can either be a remote server (e.g.
  `https://`) or a local file on the filesystem (e.g. `file://`). Often the
  metadata file contains most of the required properties for SAML
  authentication and the other parameters are not required.

`saml-idp-url`
: The base URL of the SAML IdP. This is the URL that the SAML authentication
  extension will use to redirect when requesting SAML authentication. If the
  `saml-idp-metadata-url` property is provided, this parameter will be ignored.
  If the metadata file is not provided this property is required.

`saml-entity-id`
: The entity ID of the Guacamole SAML client, which is generally the URL of the
  Guacamole server, but is not required to be so. This property is required if
  either the `saml-idp-metadata-url` property is not specified, or if the
  provided metadata file does not contain the SAML SP Entity ID for Guacamole
  Client.

`saml-callback-url`
: The URL that the IdP will use once authentication has succeeded to return to
  the Guacamole web application and provide the authentication details to the
  SAML extension. The SAML extension currently only supports callback as a POST
  operation to this callback URL. This property is required.

`saml-strict`
: Require strict security checks during SAML logins. This will insure that
  valid certificates are present for all interactions with SAML servers and
  fail SAML authentication if security restrictions are violated. This property
  is optional, and will default to true, requiring strict security checks. This
  property should only be set to false in non-production environments during
  testing of SAML authentication.

`saml-debug`
: Enable additional logging within the supporting SAML library that can assist
  in tracking down issues during SAML logins. This property is optional, and
  will default to false (no debugging).

`saml-compress-request`
: Enable compression of the HTTP requests sent to the SAML IdP. This property
  is optional and will default to true (compression enabled).

`saml-compress-response`
: Request that the SAML response returned by the IdP be compressed. This
  property is optional and will default to true (compression will be
  requested).

`saml-group-attribute`
: The name of the attribute provided by the SAML IdP that contains group
  membership of the user. These groups will be parsed and used to map group
  membership of the user logging in, which can be used for permissions
  management within Guacamole Client, particularly when layered with other
  authentication modules. This property is optional, and defaults to "groups".

### Controlling login behavior

```{include} include/sso-login-behavior.md
```

#### Automatically redirecting all unauthenticated users

To ensure users are redirected to the SAML identity provider immediately
(without a Guacamole login screen), ensure the SAML extension has priority over
all others:

```
extension-priority: saml
```

#### Presenting unauthenticated users with a login screen

To ensure users are given a normal Guacamole login screen and have the option
to log in with traditional credentials _or_ with SAML, ensure the SAML
extension does not have priority:

```
extension-priority: *, saml
```

(completing-saml-install)=

### Completing the installation

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before SAML authentication can be used. *Doing this will disconnect all active
users, so be sure that it is safe to do so prior to attempting installation.*
When ready, restart your servlet container and give the new authentication a
try.

