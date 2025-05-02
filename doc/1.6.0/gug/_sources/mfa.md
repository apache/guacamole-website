Multi-factor authentication
===========================

:::{toctree}
:hidden:

Duo <duo-auth>
TOTP <totp-auth>
:::

Multi-factor authentication (MFA) allows you to require that users verify their
identities through additional mechanisms beyond simply entering a username and
password, such as by using a mobile authenticator app. Guacamole supports the
following MFA methods:

[Duo](duo-auth)
: A proprietary MFA mechanism provided by a third-party commercial company via
  their own proprietary mobile app.

[TOTP](totp-auth)
: A standard, non-proprietary, widely supported algorithm for generating
  temporary authentication codes. This is the algorithm used by several common
  authenticator apps, including Google Authenticator.

If you are using a [single sign-on provider](sso), configuring your provider to
require MFA as part of the authentication process is also a possibility. In
this case, leveraging a dedicated Guacamole extension to provide MFA is not
necesary.
