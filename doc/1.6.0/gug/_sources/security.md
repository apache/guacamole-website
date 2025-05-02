Securing a Guacamole install
============================

:::{toctree}
:hidden:

SSL termination <reverse-proxy>
Blocking brute-force attacks <auth-ban>
:::

Secure deployment of Guacamole requires that all communication between users
and Guacamole are encrypted using SSL/TLS. We generally recommend using a
reverse proxy like Apache HTTPD or Nginx and configuring that proxy to provide
SSL termination:

[](reverse-proxy)
: SSL termination provides proper encryption in front of Guacamole without
  tying the configuration of SSL to the servlet container (Tomcat). This
  provides greater flexibility while reducing the overhead that otherwise might
  be imposed by implementing SSL within Java.

It is also highly recommended that you deploy some mechanism for brute-force
attack prevention. This ensures that malicious users that repeatedly try to
guess passwords will be automatically blocked:

[](auth-ban)
: Guacamole provides an extension that automatically recognizes repeated
  authentication failures and blocks further attempts from the same IP address.

  This is enabled by default in the `guacamole/guacamole` Docker image.

The third-party open source project, [fail2ban](https://github.com/fail2ban/fail2ban),
is also an excellent option for blocking brute-force authentication attempts,
and has the benefit of performing its blocking at the firewall level.

