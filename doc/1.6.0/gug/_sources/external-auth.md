External authentication
=======================

:::{toctree}
:hidden:

Encrypted, signed JSON <json-auth>
HTTP header <header-auth>
:::

:::{important}
**Support for [standard single sign-on methods (SSO)](sso) is also available.**
If simply looking to integrate Guacamole with an established authentication
system that provides SSO, first check whether Guacamole already supports that
SSO method.
:::

For cases where Guacamole is embedded within an external application that
performs its own authentication, extensions are provided that allow Guacamole
to easily consume the authentication result of that external application:

[HTTP header authentication](header-auth)
: Allows your external application to assert the identity of the Guacamole user
  by adding an HTTP header to authentication requests sent to Guacamole. The
  user's username is read from the HTTP header.

  The details of any underlying connections must come from anoher extension
  that supports delegation of authentication, like [any of the supported
  databases](jdbc-auth).

[Encrypted, signed JSON authentication](json-auth)
: Allows your external application to supply both identity and connection
  information within an encrypted, signed block of JSON. Encryption ensures
  that the JSON can be safely included where it may be visible to users, while
  signing ensures the JSON cannot be manipulated.

  Your application must be modified to sign and encrypt JSON as documented.

:::{hint}
For more complex cases, you may wish to look into [developing your own
Guacamole extension using the extension API ("guacamole-ext")](guacamole-ext).

The extension API is quite flexible. All authentication and authorization
methods supported by Guacamole out-of-the-box are actually provided through
[extensions written using this publicly documented API](https://github.com/apache/guacamole-client/tree/main/extensions).
:::
