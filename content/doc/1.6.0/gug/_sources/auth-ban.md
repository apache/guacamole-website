Securing Guacamole against brute-force attacks
==============================================

Version 1.6.0 of Guacamole introduces an extension that allows you to detect
and block brute-force login attacks. When installed, the extension will track
the IP addresses of failed authentication attempts. Once the threshold of
failed logins is reached for a particular IP address, further logins from that
address will be temporarily banned:

![](images/too-many-failed-logins.png)

```{include} include/warn-config-changes.md
```

Installing/Enabling brute-force authentication detection
--------------------------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:
1. Download [`guacamole-auth-ban-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-ban-1.6.0.tar.gz?action=download) from [the release page for
   Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
   and extract it.

2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

3. Copy the `guacamole-auth-ban-1.6.0.jar` file from the contents of the
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
**This extension is enabled by default when using the Docker image.** You do
not need to do anything to use this extension with Docker unless you wish to
override the default behavior. If you _don't_ wish to use this extension, you
can disable it by setting `BAN_ENABLED` to `false`.

If deploying Guacamole using Docker Compose:
: This is accomplished by adding the `BAN_ENABLED` environment
  variable to the `environment` section of your `guacamole/guacamole` container:

  ```yaml
  BAN_ENABLED: "false"
  ```

If instead deploying Guacamole by running `docker run` manually:
: This extension can be disabled by providing the same environment variable
  using the `-e` option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e BAN_ENABLED="false" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `BAN_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `BAN_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(auth-ban-config)=

Configuration (optional)
------------------------

::::{tab} Native Webapp (Tomcat)

This extension has no required properties. So long as you are satisfied
with the default behavior/values noted below, this extension requires no
configuration beyond installation.

:::{list-table} Default brute-force authentication detection threshold and limits
:stub-columns: 1
* - Maximum invalid attempts (authentication failures)
  - 5
* - Address ban duration
  - 300 (5 minutes)
* - Maximum addresses tracked
  - 10485670
:::



`ban-max-invalid-attempts`
: The number of authentication failures ater which the extension will block
  further logins from the client IP address. This property is optional and
  the default is 5.

`ban-address-duration`
: The length of time for which a client IP address will be denied logins
  after the maximum authentication failures, in seconds. This property is
  optional and has a default value of 300 seconds (five minutes).

`ban-max-addresses`
: The maximum number of client IP addresses that the extension will track
  in-memory before the oldest client IP is discarded in a Least-Recently
  Used (LRU) fashion. This property is optional and has a default value
  of 10485670 (10 million IP addresses).
::::

::::{tab} Container (Docker)

This extension has no required environment variables. So long as you are satisfied
with the default behavior/values noted below, this extension requires no
configuration beyond installation.

:::{list-table} Default brute-force authentication detection threshold and limits
:stub-columns: 1
* - Maximum invalid attempts (authentication failures)
  - 5
* - Address ban duration
  - 300 (5 minutes)
* - Maximum addresses tracked
  - 10485670
:::



`BAN_MAX_INVALID_ATTEMPTS`
: The number of authentication failures ater which the extension will block
  further logins from the client IP address. This property is optional and
  the default is 5.

`BAN_ADDRESS_DURATION`
: The length of time for which a client IP address will be denied logins
  after the maximum authentication failures, in seconds. This property is
  optional and has a default value of 300 seconds (five minutes).

`BAN_MAX_ADDRESSES`
: The maximum number of client IP addresses that the extension will track
  in-memory before the oldest client IP is discarded in a Least-Recently
  Used (LRU) fashion. This property is optional and has a default value
  of 10485670 (10 million IP addresses).
::::

:::{important}
Because the extension tracks authentication failures based on the client
IP address, it is important to make sure that Guacamole is receiving the
correct IP addresses for the clients. This is particularly noteworthy
when Guacamole is behind a reverse proxy. See the manual page on
[proxying Guacamole](reverse-proxy) for more details on configuring
Guacamole behind a proxy.
:::

(completing-auth-ban-install)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```
