HTTP header authentication
==========================

Guacamole supports delegating authentication to an arbitrary external service,
relying on the presence of an HTTP header which contains the username of the
authenticated user. This authentication method must be layered on top of some
other authentication extension, such as those available from the main project
website, in order to provide access to actual connections.

:::{danger}
**All external requests must be properly sanitized if this extension is used.**
The chosen HTTP header must be stripped from untrusted requests, such that the
authentication service is the _only_ possible source of that header.

**If such sanitization is not performed, it will be trivial for malicious users
to add this header manually, and thus gain unrestricted access.**
:::

```{include} include/warn-config-changes.md
```

(header-downloading)=

Installing/Enabling HTTP header authentication
----------------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:
1. Download [`guacamole-auth-header-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-header-1.6.0.tar.gz?action=download) from [the release page for
   Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
   and extract it.

2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

3. Copy the `guacamole-auth-header-1.6.0.jar` file from the contents of the
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
  `HTTP_AUTH_ENABLED` environment variable:

  ```yaml
  HTTP_AUTH_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e HTTP_AUTH_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `HTTP_AUTH_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `HTTP_AUTH_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(guac-header-config)=

Configuration (optional)
------------------------

::::{tab} Native Webapp (Tomcat)

This extension has no required properties. So long as you are satisfied
with the default behavior/values noted below, this extension requires no
configuration beyond installation.



`http-auth-header`
: The HTTP header containing the username of the authenticated user.
  
  This property is optional. If not specified, `REMOTE_USER` will be used by
  default. If your authentication system uses a different HTTP header you can
  use this option to override it and specify the header for Guacamole to
  expect.
::::

::::{tab} Container (Docker)

This extension has no required environment variables. So long as you are satisfied
with the default behavior/values noted below, this extension requires no
configuration beyond installation.



`HTTP_AUTH_HEADER`
: The HTTP header containing the username of the authenticated user.
  
  This property is optional. If not specified, `REMOTE_USER` will be used by
  default. If your authentication system uses a different HTTP header you can
  use this option to override it and specify the header for Guacamole to
  expect.
::::

(completing-header-install)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```
