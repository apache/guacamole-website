HTTP header authentication
==========================

Guacamole supports delegating authentication to an arbitrary external service,
relying on the presence of an HTTP header which contains the username of the
authenticated user. This authentication method must be layered on top of some
other authentication extension, such as those available from the main project
website, in order to provide access to actual connections.

:::{important}
All external requests must be properly sanitized if this extension is used. The
chosen HTTP header must be stripped from untrusted requests, such that the
authentication service is the only possible source of that header. *If such
sanitization is not performed, it will be trivial for malicious users to add
this header manually, and thus gain unrestricted access.*
:::

(header-downloading)=

Downloading the HTTP header authentication extension
----------------------------------------------------

The HTTP header authentication extension is available separately from the main
`guacamole.war`. The link for this and all other officially-supported and
compatible extensions for a particular version of Guacamole are provided on the
release notes for that version. You can find the release notes for current
versions of Guacamole here: <http://guacamole.apache.org/releases/>.

The HTTP header authentication extension is packaged as a `.tar.gz` file
containing only the extension itself, `guacamole-auth-header-1.4.0.jar`, which
must ultimately be placed in `GUACAMOLE_HOME/extensions`.

(installing-header-auth)=

Installing HTTP header authentication
-------------------------------------

Guacamole extensions are self-contained `.jar` files which are located within
the `GUACAMOLE_HOME/extensions` directory. *If you are unsure where
`GUACAMOLE_HOME` is located on your system, please consult
[](configuring-guacamole) before proceeding.*

To install the HTTP header authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-header-1.4.0.jar` within `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use HTTP header authentication, as described below.

(guac-header-config)=

### Configuring Guacamole for HTTP header authentication

The HTTP header authentication extension provides only one configuration
property, and it is optional. By default, the extension will pull the username
of the authenticated user from the `REMOTE_USER` header, if present. If your
authentication system uses a different HTTP header, you will need to override
this by specifying the `http-auth-header` property within
[`guacamole.properties`](initial-setup):

`http-auth-header`
: The HTTP header containing the username of the authenticated user.  This
  property is optional. If not specified, `REMOTE_USER` will be used by
  default.

(completing-header-install)=

### Completing the installation

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before HTTP header authentication can be used.  *Doing this will disconnect all
active users, so be sure that it is safe to do so prior to attempting
installation.* When ready, restart your servlet container and give the new
authentication a try.

