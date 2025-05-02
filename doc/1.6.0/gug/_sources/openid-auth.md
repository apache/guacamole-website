Using OpenID Connect for single sign-on
=======================================

[OpenID Connect](http://openid.net/connect/) is a widely-adopted open standard
for implementing single sign-on (SSO). [Not to be confused with
OAuth](https://oauth.net/articles/authentication/), which is *not* an
authentication protocol, OpenID Connect defines an authentication protocol in
the form of a simple identity layer on top of OAuth 2.0.

Guacamole's OpenID Connect support implements the "[implicit
flow](https://openid.net/specs/openid-connect-core-1_0.html#ImplicitFlowAuth)"
of the OpenID Connect standard, and allows authentication of Guacamole users to
be delegated to an identity provider which implements OpenID Connect, removing
the need for users to log into Guacamole directly. This module must be layered
on top of other authentication extensions that provide connection information,
such as the [database authentication extension](jdbc-auth), as it only provides
user authentication.

```{include} include/warn-config-changes.md
```

(openid-downloading)=

Installing/Enabling the OpenID Connect authentication extension
---------------------------------------------------------------

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

3. Copy the `openid/guacamole-auth-sso-openid-1.6.0.jar` file from the contents of the
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
  `OPENID_ENABLED` environment variable:

  ```yaml
  OPENID_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e OPENID_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `OPENID_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `OPENID_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(guac-openid-config)=

Required configuration
----------------------

::::{tab} Native Webapp (Tomcat)

Guacamole's OpenID connect support requires several properties
which describe both the identity provider and the Guacamole deployment. These
properties are *absolutely required in all cases*, as they dictate
how Guacamole should connect to the identity provider, how it should verify the
identity provider's response, and how the identity provider should redirect
users back to Guacamole once their identity has been confirmed:

If deploying Guacamole natively, you will need to add a section to your
`guacamole.properties` that looks like the following:

```ini
openid-authorization-endpoint: https://identity-provider/auth
openid-jwks-endpoint: https://identity-provider/jwks
openid-issuer: identity-provider
openid-client-id: my-client-id
openid-redirect-uri: https://example.net/guacamole
```

The properties that must be set in all cases for any Guacamole installation
using this extension are:


`openid-authorization-endpoint`
: The authorization endpoint (URI) of the OpenID service.
  
  This value should be provided to you by the identity provider. For identity
  providers that implement [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html),
  this value can be retrieved from the `authorization_endpoint` property of the
  JSON file hosted at {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
  `https://identity-provider` is the base URL of the identity provider.

`openid-jwks-endpoint`
: The endpoint (URI) of the JWKS service which defines how received ID tokens
  ([JSON Web Tokens](https://jwt.io/) or JWTs) shall be validated.
  
  This value should be provided to you by the identity provider. For
  identity providers that implement [OpenID Connect
  Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html),
  this value can be retrieved from the `jwks_uri` property of the JSON
  file hosted at
  {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
  `https://identity-provider` is the base URL of the identity provider.

`openid-issuer`
: The issuer to expect for all received ID tokens.
  
  This value should be provided to you by the identity provider. For
  identity providers that implement [OpenID Connect
  Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html),
  this value can be retrieved from the `issuer` property of the JSON
  file hosted at
  {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
  `https://identity-provider` is the base URL of the identity provider.

`openid-client-id`
: The OpenID client ID which should be submitted to the OpenID service when
  necessary. This value is typically provided to you by the OpenID service when
  OpenID credentials are generated for your application.

`openid-redirect-uri`
: The URI that should be submitted to the OpenID service such that they
  can redirect the authenticated user back to Guacamole after the
  authentication process is complete. This must be the full URL that a user
  would enter into their browser to access Guacamole.
::::

::::{tab} Container (Docker)

Guacamole's OpenID connect support requires several environment variables
which describe both the identity provider and the Guacamole deployment. These
environment variables are *absolutely required in all cases*, as they dictate
how Guacamole should connect to the identity provider, how it should verify the
identity provider's response, and how the identity provider should redirect
users back to Guacamole once their identity has been confirmed:

If deploying Guacamole using Docker Compose, you will need to add a set of
environment variables to the `environment` section of your
`guacamole/guacamole` container that looks like the following:

```yaml
OPENID_AUTHORIZATION_ENDPOINT: 'https://identity-provider/auth'
OPENID_JWKS_ENDPOINT: 'https://identity-provider/jwks'
OPENID_ISSUER: 'identity-provider'
OPENID_CLIENT_ID: 'my-client-id'
OPENID_REDIRECT_URI: 'https://example.net/guacamole'
```

If instead deploying Guacamole by running `docker run` manually, these same
environment variables will need to be provided using the `-e` option.  For
example:

```console
$ docker run --name some-guacamole \
    -e OPENID_AUTHORIZATION_ENDPOINT="https://identity-provider/auth" \
    -e OPENID_JWKS_ENDPOINT="https://identity-provider/jwks" \
    -e OPENID_ISSUER="identity-provider" \
    -e OPENID_CLIENT_ID="my-client-id" \
    -e OPENID_REDIRECT_URI="https://example.net/guacamole" \
    -d -p 8080:8080 guacamole/guacamole
```

The environment variables that must be set in all cases for any Docker-based
Guacamole installation using this extension are:


`OPENID_AUTHORIZATION_ENDPOINT`
: The authorization endpoint (URI) of the OpenID service.
  
  This value should be provided to you by the identity provider. For identity
  providers that implement [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html),
  this value can be retrieved from the `authorization_endpoint` property of the
  JSON file hosted at {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
  `https://identity-provider` is the base URL of the identity provider.

`OPENID_JWKS_ENDPOINT`
: The endpoint (URI) of the JWKS service which defines how received ID tokens
  ([JSON Web Tokens](https://jwt.io/) or JWTs) shall be validated.
  
  This value should be provided to you by the identity provider. For
  identity providers that implement [OpenID Connect
  Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html),
  this value can be retrieved from the `jwks_uri` property of the JSON
  file hosted at
  {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
  `https://identity-provider` is the base URL of the identity provider.

`OPENID_ISSUER`
: The issuer to expect for all received ID tokens.
  
  This value should be provided to you by the identity provider. For
  identity providers that implement [OpenID Connect
  Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html),
  this value can be retrieved from the `issuer` property of the JSON
  file hosted at
  {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
  `https://identity-provider` is the base URL of the identity provider.

`OPENID_CLIENT_ID`
: The OpenID client ID which should be submitted to the OpenID service when
  necessary. This value is typically provided to you by the OpenID service when
  OpenID credentials are generated for your application.

`OPENID_REDIRECT_URI`
: The URI that should be submitted to the OpenID service such that they
  can redirect the authenticated user back to Guacamole after the
  authentication process is complete. This must be the full URL that a user
  would enter into their browser to access Guacamole.
::::

Additional configuration (optional)
-----------------------------------

::::{tab} Native Webapp (Tomcat)

Additional optional properties are available to control how claims
within received ID tokens are used to derive the user's Guacamole username, any
associated groups, the OpenID scopes requested when user identities are
confirmed, and to control the maximum amount of time allowed for various
aspects of the conversation with the identity provider:



`openid-username-claim-type`
: The claim type within any valid JWT that contains the authenticated user's
  username. By default, the "`email`" claim type is used.

`openid-groups-claim-type`
: The claim type within any valid JWT that contains the list of groups of which
  the authenticated user is a member. By default, the "`groups`" claim type is
  used.

`openid-attributes-claim-type`
: The list of claims, separated by commas, that should be extracted from the
  JWT token and exposed as `OIDC_` attributes to use in connections. Empty by
  default.

`openid-scope`
: The space-separated list of OpenID scopes to request. OpenID scopes determine
  the information returned within the OpenID token, and thus affect what values
  can be used as an authenticated user's username.  To be compliant with
  OpenID, at least "`openid profile`" must be requested. By default, "`openid
  email profile`" is used.

`openid-allowed-clock-skew`
: The amount of clock skew tolerated for timestamp comparisons between the
  Guacamole server and OpenID service clocks, in seconds. By default, clock
  skew of up to 30 seconds is tolerated.

`openid-max-token-validity`
: The maximum amount of time that an OpenID token should remain valid, in
  minutes. By default, each OpenID token remains valid for 300 minutes (5
  hours).

`openid-max-nonce-validity`
: The maximum amount of time that a nonce generated by the Guacamole server
  should remain valid, in minutes. As each OpenID request has a unique nonce
  value, this imposes an upper limit on the amount of time any particular
  OpenID request can result in successful authentication within Guacamole. By
  default, each generated nonce expires after 10 minutes.
::::

::::{tab} Container (Docker)

Additional optional environment variables are available to control how claims
within received ID tokens are used to derive the user's Guacamole username, any
associated groups, the OpenID scopes requested when user identities are
confirmed, and to control the maximum amount of time allowed for various
aspects of the conversation with the identity provider:



`OPENID_USERNAME_CLAIM_TYPE`
: The claim type within any valid JWT that contains the authenticated user's
  username. By default, the "`email`" claim type is used.

`OPENID_GROUPS_CLAIM_TYPE`
: The claim type within any valid JWT that contains the list of groups of which
  the authenticated user is a member. By default, the "`groups`" claim type is
  used.

`OPENID_ATTRIBUTES_CLAIM_TYPE`
: The list of claims, separated by commas, that should be extracted from the
  JWT token and exposed as `OIDC_` attributes to use in connections. Empty by
  default.

`OPENID_SCOPE`
: The space-separated list of OpenID scopes to request. OpenID scopes determine
  the information returned within the OpenID token, and thus affect what values
  can be used as an authenticated user's username.  To be compliant with
  OpenID, at least "`openid profile`" must be requested. By default, "`openid
  email profile`" is used.

`OPENID_ALLOWED_CLOCK_SKEW`
: The amount of clock skew tolerated for timestamp comparisons between the
  Guacamole server and OpenID service clocks, in seconds. By default, clock
  skew of up to 30 seconds is tolerated.

`OPENID_MAX_TOKEN_VALIDITY`
: The maximum amount of time that an OpenID token should remain valid, in
  minutes. By default, each OpenID token remains valid for 300 minutes (5
  hours).

`OPENID_MAX_NONCE_VALIDITY`
: The maximum amount of time that a nonce generated by the Guacamole server
  should remain valid, in minutes. As each OpenID request has a unique nonce
  value, this imposes an upper limit on the amount of time any particular
  OpenID request can result in successful authentication within Guacamole. By
  default, each generated nonce expires after 10 minutes.
::::

(openid-login)=

### Controlling login behavior

```{include} include/sso-login-behavior.md
```

#### Automatically redirecting all unauthenticated users

To ensure users are redirected to the OpenID identity provider immediately
(without a Guacamole login screen), ensure the OpenID extension has priority
over all others:

```
extension-priority: openid
```

#### Presenting unauthenticated users with a login screen

To ensure users are given a normal Guacamole login screen and have the option
to log in with traditional credentials _or_ with OpenID, ensure the OpenID
extension does not have priority:

```
extension-priority: *, openid
```

(completing-openid-install)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```
