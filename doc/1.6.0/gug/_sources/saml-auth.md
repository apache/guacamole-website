Using SAML for single sign-on
=============================

SAML is a widely implemented and used Single Sign On (SSO) provider that allows
applications and services to authenticate in a standard way, and brokers those
authentication requests to one or more back-end authentication providers. The
SAML authentication extension allows Guacamole to redirect to a SAML Identity
Provider (IdP) for authentication and user services. This module does not
provide any capability for storing or retrieving connections, and must be
layered with other authentication extensions that provide connection
management.

```{include} include/warn-config-changes.md
```

(saml-downloading)=

Installing/Enabling the SAML authentication extension
-----------------------------------------------------

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

3. Copy the `saml/guacamole-auth-sso-saml-1.6.0.jar` file from the contents of the
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
  `SAML_ENABLED` environment variable:

  ```yaml
  SAML_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e SAML_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `SAML_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `SAML_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(guac-saml-config)=

Configuration
-------------

::::{tab} Native Webapp (Tomcat)

The SAML authentication extension provides several configuration properties to
set it up to talk to the IdP. The SAML IdP also must be configured with
Guacamole as a Service Provider (SP). Configuration of the SAML IdP is beyond
the scope of this document, and will vary widely based on the IdP in use.



`saml-idp-metadata-url`
: The URI of the XML metadata file from the SAML Identity Provider that
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
  provided metadata file does not contain the SAML SP Entity ID for the
  Guacamole Client.

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

`saml-x509-cert-path`
: The path to a certificate that will be used to sign SAML requests before
  they are sent to the IdP, enhancing the integrity of the SAML authentication
  process. This property is optional, and, if not present, SAML requests
  will not be signed.

`saml-private-key-path`
: The path to a private key file to use to encrypt SAML requests sent to the
  IdP, enhancing the confidentiality and integrity of the authentication
  process. This property is optional, and, if not present, SAML requests
  will not be encrypted before they are sent to the IdP.
::::

::::{tab} Container (Docker)

The SAML authentication extension provides several configuration properties to
set it up to talk to the IdP. The SAML IdP also must be configured with
Guacamole as a Service Provider (SP). Configuration of the SAML IdP is beyond
the scope of this document, and will vary widely based on the IdP in use.



`SAML_IDP_METADATA_URL`
: The URI of the XML metadata file from the SAML Identity Provider that
  contains all of the information the SAML extension needs in order to know how
  to authenticate with the IdP. This URI can either be a remote server (e.g.
  `https://`) or a local file on the filesystem (e.g. `file://`). Often the
  metadata file contains most of the required properties for SAML
  authentication and the other parameters are not required.

`SAML_IDP_URL`
: The base URL of the SAML IdP. This is the URL that the SAML authentication
  extension will use to redirect when requesting SAML authentication. If the
  `saml-idp-metadata-url` property is provided, this parameter will be ignored.
  If the metadata file is not provided this property is required.

`SAML_ENTITY_ID`
: The entity ID of the Guacamole SAML client, which is generally the URL of the
  Guacamole server, but is not required to be so. This property is required if
  either the `saml-idp-metadata-url` property is not specified, or if the
  provided metadata file does not contain the SAML SP Entity ID for the
  Guacamole Client.

`SAML_CALLBACK_URL`
: The URL that the IdP will use once authentication has succeeded to return to
  the Guacamole web application and provide the authentication details to the
  SAML extension. The SAML extension currently only supports callback as a POST
  operation to this callback URL. This property is required.

`SAML_STRICT`
: Require strict security checks during SAML logins. This will insure that
  valid certificates are present for all interactions with SAML servers and
  fail SAML authentication if security restrictions are violated. This property
  is optional, and will default to true, requiring strict security checks. This
  property should only be set to false in non-production environments during
  testing of SAML authentication.

`SAML_DEBUG`
: Enable additional logging within the supporting SAML library that can assist
  in tracking down issues during SAML logins. This property is optional, and
  will default to false (no debugging).

`SAML_COMPRESS_REQUEST`
: Enable compression of the HTTP requests sent to the SAML IdP. This property
  is optional and will default to true (compression enabled).

`SAML_COMPRESS_RESPONSE`
: Request that the SAML response returned by the IdP be compressed. This
  property is optional and will default to true (compression will be
  requested).

`SAML_GROUP_ATTRIBUTE`
: The name of the attribute provided by the SAML IdP that contains group
  membership of the user. These groups will be parsed and used to map group
  membership of the user logging in, which can be used for permissions
  management within Guacamole Client, particularly when layered with other
  authentication modules. This property is optional, and defaults to "groups".

`SAML_X509_CERT_PATH`
: The path to a certificate that will be used to sign SAML requests before
  they are sent to the IdP, enhancing the integrity of the SAML authentication
  process. This property is optional, and, if not present, SAML requests
  will not be signed.

`SAML_PRIVATE_KEY_PATH`
: The path to a private key file to use to encrypt SAML requests sent to the
  IdP, enhancing the confidentiality and integrity of the authentication
  process. This property is optional, and, if not present, SAML requests
  will not be encrypted before they are sent to the IdP.
::::

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

Completing installation
-----------------------

```{include} include/ext-completing.md
```
