Using Duo for multi-factor authentication
=========================================

Guacamole's Duo authentication extension allows the third-party Duo service to
be used as an additional authentication factor for users of your Guacamole
installation. If installed, users that attempt to authenticate against
Guacamole will be sent to Duo's service for further verification.

```{include} include/warn-config-changes.md
```

:::{note}
Guacamole's Duo support cannot currently be used alongside [single sign-on](sso). If
you use Duo and need both [MFA](mfa) and [SSO](sso) support for Guacamole, you
will need to either use your SSO provider's own Duo integration or use
[TOTP](totp-auth) instead of Duo.
:::

(duo-architecture)=

How Duo works with Guacamole
----------------------------

Duo is strictly a service for verifying the identities of users that have
already been partially verified through another authentication method. Thus,
for Guacamole to make use of Duo, at least one other authentication mechanism
will need be configured, such as [a supported database](jdbc-auth) or
[LDAP](ldap-auth).

When a user attempts to log into Guacamole, other installed authentication
methods will be queried first:

![](images/duo-auth-factor-1.png)

Only after authentication has succeeded with one of those methods will
Guacamole reach out to Duo to obtain additional verification of user
identity:

![](images/duo-auth-factor-2.png)

If both the initial authentication attempt and verification through Duo
succeed, the user will be allowed in. If either mechanism fails, access
to Guacamole is denied.

Adding Guacamole to Duo
-----------------------

Duo does not provide a specific integration option for Guacamole, but
Guacamole's Duo extension uses Duo's generic authentication API which
they refer to as the "Web SDK". To use Guacamole with Duo, you will need
to add it as a new "Web SDK" application from within the "Applications"
tab of the admin panel of your Duo account:

![](images/duo-add-guacamole.png)

Within the settings of the newly-added application, rename the
application to something more representative than "Web SDK". This
application name is what will be presented to your users when they are
prompted by Duo for additional authentication:

![](images/duo-rename-guacamole.png)

Once you've finished adding Guacamole as a "Web SDK" application, the
information required to configure Guacamole is listed within the application's
"Details" section. You will need to copy the client ID, secret, and API
hostname - they will later be specified within Guacamole's configuration:

![](images/duo-copy-details.png)

(duo-downloading)=

Installing/Enabling the Duo extension
-------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:
1. Download [`guacamole-auth-duo-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-duo-1.6.0.tar.gz?action=download) from [the release page for
   Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
   and extract it.

2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

3. Copy the `guacamole-auth-duo-1.6.0.jar` file from the contents of the
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
  `DUO_ENABLED` environment variable:

  ```yaml
  DUO_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e DUO_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `DUO_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `DUO_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(guac-duo-config)=

Required configuration
----------------------

::::{tab} Native Webapp (Tomcat)
If deploying Guacamole natively, you will need to add a section to your
`guacamole.properties` that looks like the following:

```ini
duo-api-hostname: api-XXXXXXXX.duosecurity.com
duo-client-id: XXXXXXXXXXXXXXXXXXXX
duo-client-secret: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
duo-redirect-uri: https://myguac.example.net
```

The properties that must be set in all cases for any Guacamole installation
using this extension are:


`duo-api-hostname`
: The hostname of the Duo API endpoint to be used to verify user identities.
  This will usually be in the form {samp}`api-{XXXXXXXX}.duosecurity.com`,
  where {samp}`{XXXXXXXX}` is some arbitrary alphanumeric value assigned by
  Duo. This value will have been generated by Duo when you added Guacamole as
  a "Web SDK" application, and can be found within the application details in
  the "API hostname" field. *This value is required.*

`duo-client-id`
: The unique client ID provided for Guacamole by Duo. This value will
  have been generated by Duo when you added Guacamole as a "Web SDK"
  application, and can be found within the application details in the
  "Client ID" field. *This value is required.*
  
  This value was formerly known as the "integration key" in older versions of
  Duo's "Web SDK" and was configured with the `duo-integration-key` property
  in older versions of Guacamole.

`duo-client-secret`
: The shared secret provided for Guacamole by Duo. This value will have been
  generated by Duo when you added Guacamole as a "Web SDK" application, and can
  be found within the application details in the "Client secret" field. *This
  value is required.*
  
  This value was formerly known as the "secret key" in older versions of Duo's
  "Web SDK" and was configured with the `duo-secret-key` property in older
  versions of Guacamole.

`duo-redirect-uri`
: The URI that should be submitted to the Duo service such that they can
  redirect the authenticated user back to Guacamole after the authentication
  process is complete. This must be the full URL that a user would enter into
  their browser to access Guacamole. *This value is required.*
::::

::::{tab} Container (Docker)
If deploying Guacamole using Docker Compose, you will need to add a set of
environment variables to the `environment` section of your
`guacamole/guacamole` container that looks like the following:

```yaml
DUO_API_HOSTNAME: 'api-XXXXXXXX.duosecurity.com'
DUO_CLIENT_ID: 'XXXXXXXXXXXXXXXXXXXX'
DUO_CLIENT_SECRET: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
DUO_REDIRECT_URI: 'https://myguac.example.net'
```

If instead deploying Guacamole by running `docker run` manually, these same
environment variables will need to be provided using the `-e` option.  For
example:

```console
$ docker run --name some-guacamole \
    -e DUO_API_HOSTNAME="api-XXXXXXXX.duosecurity.com" \
    -e DUO_CLIENT_ID="XXXXXXXXXXXXXXXXXXXX" \
    -e DUO_CLIENT_SECRET="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
    -e DUO_REDIRECT_URI="https://myguac.example.net" \
    -d -p 8080:8080 guacamole/guacamole
```

The environment variables that must be set in all cases for any Docker-based
Guacamole installation using this extension are:


`DUO_API_HOSTNAME`
: The hostname of the Duo API endpoint to be used to verify user identities.
  This will usually be in the form {samp}`api-{XXXXXXXX}.duosecurity.com`,
  where {samp}`{XXXXXXXX}` is some arbitrary alphanumeric value assigned by
  Duo. This value will have been generated by Duo when you added Guacamole as
  a "Web SDK" application, and can be found within the application details in
  the "API hostname" field. *This value is required.*

`DUO_CLIENT_ID`
: The unique client ID provided for Guacamole by Duo. This value will
  have been generated by Duo when you added Guacamole as a "Web SDK"
  application, and can be found within the application details in the
  "Client ID" field. *This value is required.*
  
  This value was formerly known as the "integration key" in older versions of
  Duo's "Web SDK" and was configured with the `duo-integration-key` property
  in older versions of Guacamole.

`DUO_CLIENT_SECRET`
: The shared secret provided for Guacamole by Duo. This value will have been
  generated by Duo when you added Guacamole as a "Web SDK" application, and can
  be found within the application details in the "Client secret" field. *This
  value is required.*
  
  This value was formerly known as the "secret key" in older versions of Duo's
  "Web SDK" and was configured with the `duo-secret-key` property in older
  versions of Guacamole.

`DUO_REDIRECT_URI`
: The URI that should be submitted to the Duo service such that they can
  redirect the authenticated user back to Guacamole after the authentication
  process is complete. This must be the full URL that a user would enter into
  their browser to access Guacamole. *This value is required.*
::::

Additional configuration (optional)
-----------------------------------

::::{tab} Native Webapp (Tomcat)

The following additional, optional properties may be set as desired
to tailor the behavior of the Duo support:



`duo-auth-timeout`
: The maximum amount of time to wait for a user to finish authenticating with
  Duo, in minutes. Any authentication attempt that takes longer than this
  amount of time will be rejected, requiring the user to reenter their
  credentials and possibly revalidate their identity with Duo. By default,
  login attempts are allowed to take up to 5 minutes.
::::

::::{tab} Container (Docker)

The following additional, optional environment variables may be set as desired
to tailor the behavior of the Duo support:



`DUO_AUTH_TIMEOUT`
: The maximum amount of time to wait for a user to finish authenticating with
  Duo, in minutes. Any authentication attempt that takes longer than this
  amount of time will be rejected, requiring the user to reenter their
  credentials and possibly revalidate their identity with Duo. By default,
  login attempts are allowed to take up to 5 minutes.
::::

### Bypass/Enforce Duo for Specific Hosts

::::{tab} Native Webapp (Tomcat)

By default, when the Duo module is enabled, Duo-based MFA will be enforced for
all users that attempt to log in to Guacamole, regardless of where they are
connecting from. Depending on your use case, it may be necessary to narrow this
behavior and only enforce Duo-based MFA for certain hosts and bypass it for
others.

```{include} include/ext-client-ips.md
```

Duo-based MFA can be explicitly bypassed or enforced on a per-host basis by
providing the relevant, exhaustive list of addresses/networks using either of
the following properties:



`duo-bypass-hosts`
: A comma-separated list of all IP addresses and/or subnets (in CIDR notation)
  that SHOULD NOT be required to verify themselves with Duo when
  authenticating. All other hosts in this list will required to verify against
  Duo.
  
  **If both bypass and enforce lists are provided, the enforce list takes
  priority and this property is effectively ignored.**
  
  This property is optional. By default, verification against Duo will be
  required for all users regardless of their IP address (Duo is not bypassed
  for any addresses).

`duo-enforce-hosts`
: A comma-separated list of all IP addresses and/or subnets (in CIDR notation)
  that SHOULD be required to verify themselves with Duo when authenticating.
  All other hosts will not be required to verify against Duo.
  
  **If both bypass and enforce lists are provided, the enforce list takes
  priority and the bypass list is effectively ignored.**
  
  This property is optional. By default, verification against Duo will be
  required for all users regardless of their IP address (Duo is enforced for
  all addresses).
::::

::::{tab} Container (Docker)

By default, when the Duo module is enabled, Duo-based MFA will be enforced for
all users that attempt to log in to Guacamole, regardless of where they are
connecting from. Depending on your use case, it may be necessary to narrow this
behavior and only enforce Duo-based MFA for certain hosts and bypass it for
others.

```{include} include/ext-client-ips.md
```

Duo-based MFA can be explicitly bypassed or enforced on a per-host basis by
providing the relevant, exhaustive list of addresses/networks using either of
the following environment variables:



`DUO_BYPASS_HOSTS`
: A comma-separated list of all IP addresses and/or subnets (in CIDR notation)
  that SHOULD NOT be required to verify themselves with Duo when
  authenticating. All other hosts in this list will required to verify against
  Duo.
  
  **If both bypass and enforce lists are provided, the enforce list takes
  priority and this property is effectively ignored.**
  
  This property is optional. By default, verification against Duo will be
  required for all users regardless of their IP address (Duo is not bypassed
  for any addresses).

`DUO_ENFORCE_HOSTS`
: A comma-separated list of all IP addresses and/or subnets (in CIDR notation)
  that SHOULD be required to verify themselves with Duo when authenticating.
  All other hosts will not be required to verify against Duo.
  
  **If both bypass and enforce lists are provided, the enforce list takes
  priority and the bypass list is effectively ignored.**
  
  This property is optional. By default, verification against Duo will be
  required for all users regardless of their IP address (Duo is enforced for
  all addresses).
::::

(completing-duo-install)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```
