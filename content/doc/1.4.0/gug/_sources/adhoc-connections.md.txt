Ad-hoc Connections
==================

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

(quickconnect-downloading)=

Downloading the quickconnect extension
--------------------------------------

The quickconnect extension is available separately from the main
`guacamole.war`. The link for this and all other officially-supported and
compatible extensions for a particular version of Guacamole are provided in the
release notes for that version. You can find the release notes for current
versions of Guacamole here: <http://guacamole.apache.org/releases/>.

The quickconnect extension is packaged as a `.tar.gz` file containing only the
extension itself, `guacamole-auth-quickconnect-1.4.0.jar`, which must
ultimately be placed in `GUACAMOLE_HOME/extensions`.

(installing-quickconnect)=

Installing the quickconnect extension
-------------------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. *If you are unsure where
`GUACAMOLE_HOME` is located on your system, please consult
[](configuring-guacamole) before proceeding.*

To install the extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Place the `guacamole-auth-quickconnect-1.4.0.jar` file in the
   `GUACAMOLE_HOME/extensions` directory.

(guac-quickconnect-config)=

### Configuring Guacamole for the quickconnect extension

The quickconnect extension has two configuration properties that allow for
controlling what connection parameters can be used in the URIs that are opened
with the quickconnect extension:

`quickconnect-allowed-parameters`
: An optional list of parameters that are allowed to be used by connections
  that are created and accessed via the quickconnect extension. If this
  property is present, only parameters in this list will be allowed. If this
  property is absent, any/all parameters will be allowed unless explicitly
  denied using the `quickconnect-denied-parameters` property.

`quickconnect-denied-parameters`
: An optional list of parameters that are explicitly denied from being used by
  connections created and accessed via the quickconnect extension. If this
  property is present, any parameters in this list will be removed from the
  connection configuration when it is created, *even if those parameter are
  listed above in the `quickconnect-allowed-parameters` property.* If this
  property is not present, no connection parameters will be explicitly denied.

(completing-quickconnect-install)=

### Completing the installation

Guacamole will only load newly-installed extensions during startup, so your
servlet container will need to be restarted before the quickconnect extension
can be used. *Doing this will disconnect all active users, so be sure that it
is safe to do so prior to attempting installation.* When ready, restart your
servlet container and give the extension a try.

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

