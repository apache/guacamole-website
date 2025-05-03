Installing Guacamole
====================

:::{toctree}
:hidden:

Native installation <guacamole-native>
Containerized (Docker) installation <guacamole-docker>
:::

There are two supported ways of installing Guacamole:

[Installing Guacamole natively](guacamole-native)
: This involves installing a servlet container like [Apache Tomcat](https://tomcat.apache.org/),
  deploying the Guacamole web application beneath Tomcat, and building at least
  guacamole-server from source.

[Installing Guacamole using Docker containers](guacamole-docker)
: This involves running a pair of Docker containers using the provided
  `guacamole/guacamole` and `guacamole/guacd` Docker images.

A typical, standard installation of Guacamole is configured to [use a database
for storage and/or authentication](jdbc-auth). This provides the most features
and flexibility, and enables a convenient [web-based administrative
interface](administration).

Other, more complex authentication methods which use [LDAP](ldap-auth), various
[multi-factor authentication](mfa) and [single sign-on options](sso), etc. are
discussed in a separate, dedicated chapters.

:::{note}
There is also a "default" authentication method that reads all users and
connections from a single file called [`user-mapping.xml`](user-mapping). This
simpler, built-in authentication method is not intended for production use, but
rather to serve as a relatively-easy means of verifying that Guacamole has been
properly set up.

It's reasonable to use this XML-based method for small deployments that don't
need the full feature set of Guacamole, but **the goal should always be to
migrate to a production-ready mechanism like [using a database](jdbc-auth)**.
We do not recommend using `user-mapping.xml` for production or anything
public-facing.
:::

