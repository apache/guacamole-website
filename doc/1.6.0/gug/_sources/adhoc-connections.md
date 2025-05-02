Creating ad-hoc connections
===========================

The quickconnect extension provides a connection bar on the Guacamole Client
home page that allows users to type in the URI of a server to which they want
to connect and the client will parse the URI and immediately establish the
connection. The purpose of the extension is to allow situations where
administrators want to allow users the flexibility of establishing their own
connections without having to grant them access to edit connections or even to
have to create the connections at all, aside from typing the URI.

:::{important}
There are several implications of using this extension that should be
well-understood by administrators prior to implementing it:

* Connections established with this extension are created in-memory and only
  persist until the Guacamole session ends.

* Connections created with this extension are not accessible to other users,
  and cannot be shared with other users.

* This extension provides no functionality for authenticating users - it does
  not allow anonymous logins, and requires that users are successfully
  authenticated by another authentication module before it can be used.

* The extension provides users the ability not only to establish connections,
  but also to set any of the parameters for a connection. There are security
  implications for this - for example, RDP file sharing can be used to pass
  through any directory available on the server running guacd to the remote
  desktop. This should be taken into consideration when enabling this extension
  and making sure that guacd is configured in a way that does not compromise
  sensitive system files by allowing access to them.
:::

```{include} include/warn-config-changes.md
```

(quickconnect-downloading)=

Installing/Enabling the quickconnect extension
----------------------------------------------

Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

::::{tab} Native Webapp (Tomcat)
Native installations of Guacamole under [Apache Tomcat](https://tomcat.apache.org/)
or similar are configured by modifying the contents of `GUACAMOLE_HOME`
([Guacamole's configuration directory](guacamole-home)), which is located at
`/etc/guacamole` by default and may need to be created first:
1. Download [`guacamole-auth-quickconnect-1.6.0.tar.gz`](https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-quickconnect-1.6.0.tar.gz?action=download) from [the release page for
   Apache Guacamole 1.6.0](https://guacamole.apache.org/releases/1.6.0)
   and extract it.

2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

3. Copy the `guacamole-auth-quickconnect-1.6.0.jar` file from the contents of the
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
  `QUICKCONNECT_ENABLED` environment variable:

  ```yaml
  QUICKCONNECT_ENABLED: "true"
  ```

If instead deploying Guacamole by running `docker run` manually:
: The same environment variable(s) will need to be provided using the `-e`
  option. For example:

  ```console
  $ docker run --name some-guacamole \
      -e QUICKCONNECT_ENABLED="true" \
      -d -p 8080:8080 guacamole/guacamole
  ```

If `QUICKCONNECT_ENABLED` is set to `false`, the extension will NOT be
installed, even if other related environment variables have been set. This can
be used to temporarily disable usage of an extension without needing to remove
all other related configuration.

You don't strictly need to set `QUICKCONNECT_ENABLED` if other related
environment variables are provided, but the extension will be installed only if
at least _one_ related environment variable is set.
::::

(guac-quickconnect-config)=

Configuration (optional)
------------------------

::::{tab} Native Webapp (Tomcat)

This extension has no required properties. So long as you are satisfied
with the default behavior/values noted below, this extension requires no
configuration beyond installation.



`quickconnect-allowed-parameters`
: An optional list of parameters that are allowed to be used by connections
  that are created and accessed via the quickconnect extension. If provided,
  only parameters in this list will be allowed.

`quickconnect-denied-parameters`
: An optional list of parameters that are explicitly denied from being used by
  connections created and accessed via the quickconnect extension. If provided,
  any parameters in this list will be removed from the connection configuration
  when it is created, **even if those parameters are otherwise explicitly
  listed as allowed**.
::::

::::{tab} Container (Docker)

This extension has no required environment variables. So long as you are satisfied
with the default behavior/values noted below, this extension requires no
configuration beyond installation.



`QUICKCONNECT_ALLOWED_PARAMETERS`
: An optional list of parameters that are allowed to be used by connections
  that are created and accessed via the quickconnect extension. If provided,
  only parameters in this list will be allowed.

`QUICKCONNECT_DENIED_PARAMETERS`
: An optional list of parameters that are explicitly denied from being used by
  connections created and accessed via the quickconnect extension. If provided,
  any parameters in this list will be removed from the connection configuration
  when it is created, **even if those parameters are otherwise explicitly
  listed as allowed**.
::::

(completing-quickconnect-install)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```

(using-quickconnect)=

Using the quickconnect extension
--------------------------------

The quickconnect extension provides a field on the home page that allows you to
enter a Uniform Resource Identifier (URI) to create a connection. A URI is in
the form:

{samp}`{protocol}://{username}:{password}@{host}:{port}/?{parameters}`

The `protocol` field can have any of the protocols supported by Guacamole, as
documented in [](configuring-guacamole). Many of the protocols define a default
`port` value, with the exception of VNC. The `parameters` field can specify any
of the protocol-specific parameters as documented on the configuration page.

To establish a connection, simply type in a valid URI and either press "Enter"
or click the connect button. This extension will parse the URI and create a new
connection, and immediately start that connection in the current browser.

Here are a few examples of URIs:

`ssh://linux1.example.com/`
: Connect to the server linux1.example.com using the SSH protocol on the
  default SSH port (22). This will result in prompting for both username and
  password.

`vnc://linux1.example.com:5900/`
: Connect to the server linux1.example.com using the VNC protocol and
  specifying the port as 5900.

`rdp://localuser@windows1.example.com/?security=rdp&ignore-cert=true&disable-audio=true&enable-drive=true&drive-path=/mnt/usb`
: Connect to the server windows1.example.com using the RDP protocol and the
  user "localuser". This URI also specifies several RDP-specific parameters on
  the connection, including forcing security mode to RDP (security=rdp), ignoring
  any certificate errors (ignore-cert=true), disabling audio pass-through
  (disable-audio=true), and enabling filesystem redirection (enable-drive=true)
  to the /mnt/usb folder on the system running guacd (drive-path=/mnt/usb).
