Signing in with smart cards or certificates
===========================================

Single sign-on using SSL client authentication depends on having a reverse
proxy configured to provide SSL termination for Guacamole. Unlike a standard
reverse proxy setup, however, a portion of the requests served through the
proxy will verify the client's identity using SSL client authentication and
pass that information on to Guacamole.

```{include} include/warn-config-changes.md
```

How SSL client authentication works with Guacamole
--------------------------------------------------

Using SSL client authentication for Guacamole involves configuring a reverse
proxy to provide SSL termination for the same instance of Guacamole at two
different domains or subdomains:

1. **A wildcard subdomain and certificate** that will be used strictly for
   performing SSL client authentication. The wildcard certificate is necessary
   to allow Guacamole to generate temporary subdomains and avoid browser
   caching of credentials.

2. **A normal domain/subdomain (and corresponding certificate)** that will be
   used for Guacamole itself and will not use SSL client authentication.

When Guacamole is configured for single sign-on using SSL client
authentication, users are presented with an additional "Certificate / Smart
Card" option at the bottom of the login screen:

![The Guacamole login screen, showing the "Certificate / Smart Card" prompt added by the SSL client authentication extension.](images/ssl-sso-001-link.png)

If a user clicks on "Certificate / Smart Card", Guacamole generates a temporary
subdomain to handle authentication and redirects the user to that subdomain. As
the SSL termination is configured to handle these subdomains with SSL client
authentication, the user is authenticated by the reverse proxy using that
mechanism:

![The browser prompt resulting from starting the SSL client authentication process by clicking the "Certificate / Smart Card" link, displayed in front of the Guacamole login screen.](images/ssl-sso-002-browser-prompt.png)

The reverse proxy notifies Guacamole of the result of authentication using the
`X-Client-Verified` and `X-Client-Certificate` headers. Once the user is
authenticated (or fails to authenticate), Guacamole redirects the user back to
the primary domain and their SSL authentication result is read.

If the user successfully authenticated, their username is determined from the
certificate:

![The Guacamole home screen after successfully signing in using a smart card.](images/ssl-sso-003-success.png)

If the user _did not_ successfully authenticate, authentication with Guacamole
fails and the user sees the login screen again.

(ssl-auth-configuring-proxy)=

Configuring SSL termination to use client authentication
--------------------------------------------------------

There are two separate configurations that will need to be applied to your
reverse proxy, one for each of the domains noted above. In each case, the proxy
will need to add headers that will be consumed by Guacamole's SSL
authentication integration.

:::{hint}
The `*.auth.guac.example.net` and `guac.example.net` domains are used
throughout this documentation as representative placeholders. Your
configuration will differ depending on the domain your users are using to
access your instance of Guacamole.

Both the wildcard domain and normal domain that will be configured here will
need to be referenced in Guacamole's configuration. Take note of these domains,
so that you can provide their values when configuring Guacamole later.
:::

### Wildcard domain (performs SSL client authentication)

Since it is the wildcard domain that will actually perform SSL client
authentication (Guacamole receives the authentication result from your reverse
proxy via HTTP headers), the configuration for the wildcard domain requires
several additional changes from [the standard reverse proxy configuration for
Guacamole](reverse-proxy):

Enable SSL client authentication in "optional" mode
: This will result in the reverse proxy requesting authentication, but will
  not prohibit the authentication result from being sent on to Guacamole if
  authentication fails.

Pass through the `Host` header received by the reverse proxy
: It is the `Host` header that determines whether the request is routed to the
  reverse proxy's handling of wildcard domain vs. normal domain, and Guacamole
  needs this information, as well, to determine context.

Include the authentication result as the value of the `X-Client-Verified` header.
: This header must contain the value `SUCCESS` if authentication succeeded and
  may contain any other value otherwise. If authentication failed, this header
  may contain `FAILED:` followed by a human-readable description of the
  failure, and Guacamole will include that description in its logs.

  Both the Apache HTTP Server and Nginx support this format for passing on the
  result of SSL client authentication.

Include the URL-encoded client certificate in PEM format as the value `X-Client-Certificate` header.
: Here, URL encoding is necessary to allow the certificate to be included as
  the value of an HTTP header. Both the Apache HTTP Server and Nginx support
  URL encoding of this value.

_The portions of the reverse proxy configuration which differ from [the
standard configuration](reverse-proxy) are highlighted below._ Your reverse
proxy configuration will need to be similarly modified to allow Guacamole to
receive and process the authentication result.

::::{tab} Apache HTTP Server
:::{code-block} apache
:emphasize-lines: 3-4,10-12,21-23
<VirtualHost *:443>

    ServerName x.auth.guac.example.net
    ServerAlias *.auth.guac.example.net

    SSLEngine on
    SSLCertificateFile "/etc/ssl/certs/_.auth.guac.example.net.crt"
    SSLCertificateKeyFile "/etc/ssl/private/_.auth.guac.example.net.key"

    SSLCACertificateFile "/etc/ssl/certs/client-auth-ca-certs.crt"
    SSLVerifyClient optional
    SSLVerifyDepth 2

    <Location /guacamole/>

        Order allow,deny
        Allow from all
        ProxyPass http://localhost:8080/guacamole/ flushpackets=on
        ProxyPassReverse http://localhost:8080/guacamole/

        ProxyPreserveHost on
        RequestHeader set X-Client-Certificate "expr=%{escape:%{SSL_CLIENT_CERT}}"
        RequestHeader set X-Client-Verified "%{SSL_CLIENT_VERIFY}s"

    </Location>

</VirtualHost>
:::

:::{hint}
The [typical `<Location /guacamole/websocket-tunnel>`
section](websocket-and-apache) is intentionally omitted above. This is because
SSL client authentication will be performed only via a specific, dedicated
endpoint that does not involve any tunnel, let alone the WebSocket tunnel.

Including a `<Location>` section for the `websocket-tunnel` endpoint beneath
the wildcard domain will not prevent smart card / certificate authentication
from working, but it is unnecessary for the wildcard domain.
:::

::::

::::{tab} Nginx
:::{code-block} nginx
:emphasize-lines: 4,9-10,22-24
server {

    listen 443 ssl;
    server_name _.auth.guac.example.net;

    ssl_certificate /etc/ssl/certs/_.auth.guac.example.net.crt;
    ssl_certificate_key /etc/ssl/private/_.auth.guac.example.net.key;

    ssl_client_certificate /etc/ssl/certs/client-auth-ca-certs.crt;
    ssl_verify_client optional;

    location /guacamole/ {

        proxy_pass http://localhost:8080;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        access_log off;

        proxy_set_header Host $http_host;
        proxy_set_header X-Client-Verified $ssl_client_verify;
        proxy_set_header X-Client-Certificate $ssl_client_escaped_cert;

    }

}
:::
::::

### Normal domain (does not perform SSL client authentication)

Configuration of the non-wildcard, normal domain is simpler than its wildcard
counterpart, but still requires at least pass-through of the `Host` header
received by the reverse proxy. As with the wildcard domain, this is necessary
for Guacamole to determine the context of the request it received.

::::{tab} Apache HTTP Server
:::{code-block} apache
:emphasize-lines: 3,14
<VirtualHost *:443>

    ServerName guac.example.net

    SSLEngine on
    SSLCertificateFile "/etc/ssl/certs/guac.example.net.crt"
    SSLCertificateKeyFile "/etc/ssl/private/guac.example.net.key"

    <Location /guacamole/>
        Order allow,deny
        Allow from all
        ProxyPass http://localhost:8080/guacamole/ flushpackets=on
        ProxyPassReverse http://localhost:8080/guacamole/
        ProxyPreserveHost on
    </Location>

    <Location /guacamole/websocket-tunnel>
        Order allow,deny
        Allow from all
        ProxyPass ws://localhost:8080/guacamole/websocket-tunnel
        ProxyPassReverse ws://localhost:8080/guacamole/websocket-tunnel
    </Location>

</VirtualHost>
:::
::::

::::{tab} Nginx
:::{code-block} nginx
:emphasize-lines: 4,13
server {

    listen 443 ssl;
    server_name guac.example.net;

    ssl_certificate /etc/ssl/certs/guac.example.net.crt;
    ssl_certificate_key /etc/ssl/private/guac.example.net.key;

    location /guacamole/ {
        proxy_pass http://localhost:8080;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        access_log off;
    }

}
:::
::::

With both the wildcard and normal domains configured, your reverse proxy should
be ready to handle SSL client authentication and pass on the results of any
authentication attempts to Guacamole in the format expected.

(ssl-auth-downloading)=

Installing/Enabling the SSL client authentication extension
-----------------------------------------------------------

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

3. Copy the `ssl/guacamole-auth-sso-ssl-1.6.0.jar` file from the contents of the
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
  `SSL_AUTH_ENABLED` environment variable:

  ```yaml
  SSL_AUTH_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e SSL_AUTH_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `SSL_AUTH_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `SSL_AUTH_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(ssl-auth-config)=

Required configuration
----------------------

::::{tab} Native Webapp (Tomcat)

Guacamole's SSL client authentication support requires two properties which describe the domains that your reverse proxy has been configured to
use for authentication and for simply accessing Guacamole. These properties
are *absolutely required in all cases*:

If deploying Guacamole natively, you will need to add a section to your
`guacamole.properties` that looks like the following:

```ini
ssl-auth-uri: https://*.auth.guac.example.net
ssl-auth-primary-uri: https://guac.example.net
```

The properties that must be set in all cases for any Guacamole installation
using this extension are:


`ssl-auth-uri`
: The URI that should be used to authenticate users with SSL/TLS client
  authentication. This must be a URI that points to THIS instance of Guacamole,
  but behind SSL termination that requires SSL/TLS client authentication.

`ssl-auth-primary-uri`
: The URI of this instance without SSL/TLS client authentication required. This
  must be a URI that points to THIS instance of Guacamole, but behind SSL
  termination that DOES NOT require or request SSL/TLS client authentication.
::::

::::{tab} Container (Docker)

Guacamole's SSL client authentication support requires two environment variables which describe the domains that your reverse proxy has been configured to
use for authentication and for simply accessing Guacamole. These environment variables
are *absolutely required in all cases*:

If deploying Guacamole using Docker Compose, you will need to add a set of
environment variables to the `environment` section of your
`guacamole/guacamole` container that looks like the following:

```yaml
SSL_AUTH_URI: 'https://*.auth.guac.example.net'
SSL_AUTH_PRIMARY_URI: 'https://guac.example.net'
```

If instead deploying Guacamole by running `docker run` manually, these same
environment variables will need to be provided using the `-e` option.  For
example:

```console
$ docker run --name some-guacamole \
    -e SSL_AUTH_URI="https://*.auth.guac.example.net" \
    -e SSL_AUTH_PRIMARY_URI="https://guac.example.net" \
    -d -p 8080:8080 guacamole/guacamole
```

The environment variables that must be set in all cases for any Docker-based
Guacamole installation using this extension are:


`SSL_AUTH_URI`
: The URI that should be used to authenticate users with SSL/TLS client
  authentication. This must be a URI that points to THIS instance of Guacamole,
  but behind SSL termination that requires SSL/TLS client authentication.

`SSL_AUTH_PRIMARY_URI`
: The URI of this instance without SSL/TLS client authentication required. This
  must be a URI that points to THIS instance of Guacamole, but behind SSL
  termination that DOES NOT require or request SSL/TLS client authentication.
::::

Additional configuration (optional)
-----------------------------------

::::{tab} Native Webapp (Tomcat)

Additional optional properties are available to control how the
requests received from your reverse proxy are processed, including narrowing
the distinguished names (DNs) that should be accepted as valid:



`ssl-auth-client-certificate-header`
: The name of the header to use to retrieve the URL-encoded client certificate
  from an HTTP request received from an SSL termination service providing
  SSL/TLS client authentication. The certificate must be in PEM format.
  
  By default, the `X-Client-Certificate` header will be used.

`ssl-auth-client-verified-header`
: The name of the header to use to retrieve the verification status of the
  certificate an HTTP request received from an SSL termination service
  providing SSL/TLS client authentication.
  
  The value of this header must be "SUCCESS" (all uppercase) if the certificate
  was successfully verified. The full set of accepted values that your reverse
  proxy should submit for this header is:
  
  `SUCCESS`
  : Client certificate verification succeeded.
  
  {samp}`FAILED: {reason}`
  : Client certificate verification failed for the given reason (a
    human-readable description).
  
  `NONE`
  : No client certificate was present.
  
  This matches the values used by both the Apache HTTP Server and Nginx. Any
  value not shown above is interpreted as an authentication failure.
  
  By default, the `X-Client-Verified` header will be used.

`ssl-auth-max-token-validity`
: The amount of time that a temporary authentication token for SSL/TLS
  authentication may remain valid, in minutes.
  
  This token is used to represent the user's asserted identity after it has
  been verified by the SSL termination service. This interval must be long
  enough to allow for network delays in receiving the token, but short enough
  that unused tokens do not consume unnecessary server resources and cannot
  potentially be guessed while the token is still valid. These tokens are
  256-bit secure random values.
  
  By default, tokens are valid for 5 minutes.

`ssl-auth-subject-username-attribute`
: The LDAP attribute or attributes that may be used to represent a username
  within the subject DN of a user's X.509 certificate. If the least-significant
  attribute of the subject DN is not one of these attributes, the certificate
  will be rejected.
  
  By default, any attribute is accepted (the least-significant attribute of the
  subject DN is used as the username, regardless of what attribute that may
  be).

`ssl-auth-subject-base-dn`
: The base DN containing all valid subject DNs. If specified, only certificates
  asserting subject DNs beneath this base DN will be accepted.
  
  By default, all DNs are accepted.

`ssl-auth-max-domain-validity`
: The amount of time that the temporary, unique subdomain generated for SSL/TLS
  authentication may remain valid, in minutes. This subdomain is used to ensure
  each SSL/TLS authentication attempt is fresh and does not potentially reuse a
  previous authentication attempt that was cached by the browser or OS. This
  interval must be long enough to allow for network delays in authenticating
  the user with the SSL termination service that enforces SSL/TLS client
  authentication, but short enough that an unused domain does not consume
  unnecessary server resources and cannot potentially be guessed while that
  subdomain is still valid. These subdomains are 128-bit secure random values.
  
  By default, generated domains are valid for 5 minutes.
::::

::::{tab} Container (Docker)

Additional optional environment variables are available to control how the
requests received from your reverse proxy are processed, including narrowing
the distinguished names (DNs) that should be accepted as valid:



`SSL_AUTH_CLIENT_CERTIFICATE_HEADER`
: The name of the header to use to retrieve the URL-encoded client certificate
  from an HTTP request received from an SSL termination service providing
  SSL/TLS client authentication. The certificate must be in PEM format.
  
  By default, the `X-Client-Certificate` header will be used.

`SSL_AUTH_CLIENT_VERIFIED_HEADER`
: The name of the header to use to retrieve the verification status of the
  certificate an HTTP request received from an SSL termination service
  providing SSL/TLS client authentication.
  
  The value of this header must be "SUCCESS" (all uppercase) if the certificate
  was successfully verified. The full set of accepted values that your reverse
  proxy should submit for this header is:
  
  `SUCCESS`
  : Client certificate verification succeeded.
  
  {samp}`FAILED: {reason}`
  : Client certificate verification failed for the given reason (a
    human-readable description).
  
  `NONE`
  : No client certificate was present.
  
  This matches the values used by both the Apache HTTP Server and Nginx. Any
  value not shown above is interpreted as an authentication failure.
  
  By default, the `X-Client-Verified` header will be used.

`SSL_AUTH_MAX_TOKEN_VALIDITY`
: The amount of time that a temporary authentication token for SSL/TLS
  authentication may remain valid, in minutes.
  
  This token is used to represent the user's asserted identity after it has
  been verified by the SSL termination service. This interval must be long
  enough to allow for network delays in receiving the token, but short enough
  that unused tokens do not consume unnecessary server resources and cannot
  potentially be guessed while the token is still valid. These tokens are
  256-bit secure random values.
  
  By default, tokens are valid for 5 minutes.

`SSL_AUTH_SUBJECT_USERNAME_ATTRIBUTE`
: The LDAP attribute or attributes that may be used to represent a username
  within the subject DN of a user's X.509 certificate. If the least-significant
  attribute of the subject DN is not one of these attributes, the certificate
  will be rejected.
  
  By default, any attribute is accepted (the least-significant attribute of the
  subject DN is used as the username, regardless of what attribute that may
  be).

`SSL_AUTH_SUBJECT_BASE_DN`
: The base DN containing all valid subject DNs. If specified, only certificates
  asserting subject DNs beneath this base DN will be accepted.
  
  By default, all DNs are accepted.

`SSL_AUTH_MAX_DOMAIN_VALIDITY`
: The amount of time that the temporary, unique subdomain generated for SSL/TLS
  authentication may remain valid, in minutes. This subdomain is used to ensure
  each SSL/TLS authentication attempt is fresh and does not potentially reuse a
  previous authentication attempt that was cached by the browser or OS. This
  interval must be long enough to allow for network delays in authenticating
  the user with the SSL termination service that enforces SSL/TLS client
  authentication, but short enough that an unused domain does not consume
  unnecessary server resources and cannot potentially be guessed while that
  subdomain is still valid. These subdomains are 128-bit secure random values.
  
  By default, generated domains are valid for 5 minutes.
::::

(ssl-auth-completing)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```
