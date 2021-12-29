OpenID Connect Authentication
=============================

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

(openid-downloading)=

Downloading the OpenID Connect authentication extension
-------------------------------------------------------

```{include} include/sso-download.md
```

The extension for the desired SSO method, in this case
`guacamole-auth-sso-openid-1.4.0.jar` from within the `openid/` subdirectory,
must ultimately be placed in `GUACAMOLE_HOME/extensions`.

(installing-openid-auth)=

Installing support for OpenID Connect
-------------------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. *If you are unsure where
`GUACAMOLE_HOME` is located on your system, please consult
[](configuring-guacamole) before proceeding.*

To install the OpenID Connect authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-sso-openid-1.4.0.jar` within
   `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use OpenID Connect authentication, as described
   below.

(guac-openid-config)=

### Configuring Guacamole for single sign-on with OpenID Connect

Guacamole's OpenID connect support requires several properties which describe
both the identity provider and the Guacamole deployment. These properties are
*absolutely required in all cases*, as they dictate how Guacamole should
connect to the identity provider, how it should verify the identity provider's
response, and how the identity provider should redirect users back to Guacamole
once their identity has been confirmed:

`openid-authorization-endpoint`
: The authorization endpoint (URI) of the OpenID service.

  This value should be provided to you by the identity provider. For identity
  providers that implement [OpenID Connect
  Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html), this
  value can be retrieved from the `authorization_endpoint` property of the JSON
  file hosted at
  {samp}`{https://identity-provider}/.well-known/openid-configuration`, where
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

Additional optional properties are available to control how claims within
received ID tokens are used to derive the user's Guacamole username, any
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

`openid-scope`
: The space-separated list of OpenID scopes to request. OpenID scopes determine
  the information returned within the OpenID token, and thus affect what values
  can be used as an authenticated user's username.  To be compliant with OpenID,
  at least "`openid profile`" must be requested. By default, "`openid email
  profile`" is used.

`openid-allowed-clock-skew`
: The amount of clock skew tolerated for timestamp comparisons between the
  Guacamole server and OpenID service clocks, in seconds. By default, clock skew
  of up to 30 seconds is tolerated.

`openid-max-token-validity`
: The maximum amount of time that an OpenID token should remain valid, in
  minutes. By default, each OpenID token remains valid for 300 minutes (5
  hours).

`openid-max-nonce-validity`
: The maximum amount of time that a nonce generated by the Guacamole
  server should remain valid, in minutes. As each OpenID request has a unique
  nonce value, this imposes an upper limit on the amount of time any particular
  OpenID request can result in successful authentication within Guacamole. By
  default, each generated nonce expires after 10 minutes.

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

### Completing the installation

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before OpenID Connect authentication can be used. *Doing this will disconnect
all active users, so be sure that it is safe to do so prior to attempting
installation.* When ready, restart your servlet container and give the new
authentication a try.

