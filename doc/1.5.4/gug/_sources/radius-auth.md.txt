RADIUS Authentication
=====================

Guacamole supports delegating authentication to a RADIUS service, such as
FreeRADIUS, to validate username and password combinations, and to support
multi-factor authentication. This authentication method must be layered on top
of some other authentication extension, such as those available from the main
project website, in order to provide access to actual connections.

(radius-downloading)=

Downloading the RADIUS authentication extension
-----------------------------------------------

The RADIUS extension depends on software that is covered by a LGPL license,
which is incompatible with the Apache 2.0 license under which Guacamole is
licensed. Due to this dependency, the Guacamole project cannot distribute
binary versions of the RADIUS extension. If you want to use this extension you
will need to build the code - or at least the RADIUS extension yourself. Build
instructions can be found in the section [](installing-guacamole).

(installing-radius-auth)=

Installing RADIUS authentication
--------------------------------

The RADIUS extension must be explicitly enabled during build time in order to
generate the binaries and resulting JAR file. This is done by adding the flag
`-Plgpl-extensions` to the Maven command line during the build, and should
result in the output below:

   :::{code-block} console
   :emphasize-lines: 35,71
   $ mvn clean package -Plgpl-extensions
   [INFO] Scanning for projects...
   [INFO] ------------------------------------------------------------------------
   [INFO] Reactor Build Order:
   [INFO] 
   [INFO] guacamole-client                                                   [pom]
   [INFO] guacamole-common                                                   [jar]
   [INFO] guacamole-ext                                                      [jar]
   [INFO] guacamole-common-js                                                [pom]
   [INFO] guacamole                                                          [war]
   [INFO] extensions                                                         [pom]
   [INFO] guacamole-auth-duo                                                 [jar]
   [INFO] guacamole-auth-header                                              [jar]
   [INFO] guacamole-auth-jdbc                                                [pom]
   [INFO] guacamole-auth-jdbc-base                                           [jar]
   [INFO] guacamole-auth-jdbc-mysql                                          [jar]
   [INFO] guacamole-auth-jdbc-postgresql                                     [jar]
   [INFO] guacamole-auth-jdbc-sqlserver                                      [jar]
   [INFO] guacamole-auth-jdbc-dist                                           [pom]
   [INFO] guacamole-auth-json                                                [jar]
   [INFO] guacamole-auth-ldap                                                [jar]
   [INFO] guacamole-auth-quickconnect                                        [jar]
   [INFO] guacamole-auth-sso                                                 [pom]
   [INFO] guacamole-auth-sso-base                                            [jar]
   [INFO] guacamole-auth-sso-cas                                             [jar]
   [INFO] guacamole-auth-sso-openid                                          [jar]
   [INFO] guacamole-auth-sso-saml                                            [jar]
   [INFO] guacamole-auth-sso-dist                                            [pom]
   [INFO] guacamole-auth-totp                                                [jar]
   [INFO] guacamole-history-recording-storage                                [jar]
   [INFO] guacamole-vault                                                    [pom]
   [INFO] guacamole-vault-base                                               [jar]
   [INFO] guacamole-vault-ksm                                                [jar]
   [INFO] guacamole-vault-dist                                               [pom]
   [INFO] guacamole-auth-radius                                              [jar]
   [INFO] guacamole-example                                                  [war]
   [INFO] guacamole-playback-example                                         [war]
   ...
   [INFO] ------------------------------------------------------------------------
   [INFO] Reactor Summary for guacamole-client 1.5.4:
   [INFO] 
   [INFO] guacamole-client ................................... SUCCESS [ 12.839 s]
   [INFO] guacamole-common ................................... SUCCESS [ 15.446 s]
   [INFO] guacamole-ext ...................................... SUCCESS [ 19.988 s]
   [INFO] guacamole-common-js ................................ SUCCESS [ 22.000 s]
   [INFO] guacamole .......................................... SUCCESS [01:08 min]
   [INFO] extensions ......................................... SUCCESS [  0.451 s]
   [INFO] guacamole-auth-duo ................................. SUCCESS [  7.043 s]
   [INFO] guacamole-auth-header .............................. SUCCESS [  4.836 s]
   [INFO] guacamole-auth-jdbc ................................ SUCCESS [  0.244 s]
   [INFO] guacamole-auth-jdbc-base ........................... SUCCESS [  8.011 s]
   [INFO] guacamole-auth-jdbc-mysql .......................... SUCCESS [  4.717 s]
   [INFO] guacamole-auth-jdbc-postgresql ..................... SUCCESS [  5.098 s]
   [INFO] guacamole-auth-jdbc-sqlserver ...................... SUCCESS [  5.620 s]
   [INFO] guacamole-auth-jdbc-dist ........................... SUCCESS [  4.031 s]
   [INFO] guacamole-auth-json ................................ SUCCESS [  6.319 s]
   [INFO] guacamole-auth-ldap ................................ SUCCESS [  8.948 s]
   [INFO] guacamole-auth-quickconnect ........................ SUCCESS [  9.128 s]
   [INFO] guacamole-auth-sso ................................. SUCCESS [  0.270 s]
   [INFO] guacamole-auth-sso-base ............................ SUCCESS [  3.665 s]
   [INFO] guacamole-auth-sso-cas ............................. SUCCESS [ 12.263 s]
   [INFO] guacamole-auth-sso-openid .......................... SUCCESS [  5.667 s]
   [INFO] guacamole-auth-sso-saml ............................ SUCCESS [  5.068 s]
   [INFO] guacamole-auth-sso-dist ............................ SUCCESS [  4.884 s]
   [INFO] guacamole-auth-totp ................................ SUCCESS [  9.310 s]
   [INFO] guacamole-history-recording-storage ................ SUCCESS [  3.131 s]
   [INFO] guacamole-vault .................................... SUCCESS [  0.231 s]
   [INFO] guacamole-vault-base ............................... SUCCESS [  4.671 s]
   [INFO] guacamole-vault-ksm ................................ SUCCESS [  6.411 s]
   [INFO] guacamole-vault-dist ............................... SUCCESS [  3.421 s]
   [INFO] guacamole-auth-radius .............................. SUCCESS [ 10.806 s]
   [INFO] guacamole-example .................................. SUCCESS [  2.052 s]
   [INFO] guacamole-playback-example ......................... SUCCESS [  0.938 s]
   [INFO] ------------------------------------------------------------------------
   [INFO] BUILD SUCCESS
   [INFO] ------------------------------------------------------------------------
   [INFO] Total time:  04:36 min
   [INFO] Finished at: 2023-01-10T17:27:11-08:00
   [INFO] ------------------------------------------------------------------------
   $
   :::

After the build completes successfully, the extension will be in the
`extensions/guacamole-auth-radius/target/` directory, and will be called
guacamole-auth-radius-1.5.4.jar. This extension file can be copied to the
`GUACAMOLE_HOME/extensions` directory. *If you are unsure where
`GUACAMOLE_HOME` is located on your system, please consult
[](configuring-guacamole) before proceeding.*

Extensions are loaded in alphabetical order, and authentication is performed in
the order in which the extensions were loaded. If you are stacking the RADIUS
extension with another extension, like the JDBC extension, in order to store
connection information, you may need to change the name of the RADIUS extension
such that it is evaluated prior to the JDBC extension - otherwise an
authentication failure in one of the previous modules may block the RADIUS
module from ever being evaluated.

To install the RADIUS authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-radius-1.5.4.jar` into `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use RADIUS authentication, as described below.

(guac-radius-config)=

Configuring Guacamole for RADIUS authentication
-----------------------------------------------

This extension provides several configuration properties in order to
communicate properly with the RADIUS server to which it needs to authenticate.
It is important that you know several key pieces of information about the
RADIUS server - at a minimum, the server name or IP, the authentication port,
the authentication protocol in use by the server, and the shared secret for the
RADIUS client. If you are responsible for the RADIUS server, you'll need to
properly configure these items to get Guacamole to authenticate properly. If
you're not responsible for the RADIUS server you will need to work with the
administrator to get all of the necessary configuration items for the server.
These items will need to be configured in the
[`guacamole.properties`](initial-setup) file.

`radius-hostname`
: The RADIUS server to authenticate against. If not specified, localhost will
  be used.

`radius-auth-port`
: The RADIUS authentication port on which the RADIUS service is is listening.
  If not specified, the default of 1812 will be used.

`radius-shared-secret`
: The shared secret to use when talking to the RADIUS server. This parameter is
  required and the extension will not load if this is not specified.

`radius-auth-protocol`
: The authentication protocol to use when talking to the RADIUS server. This
  parameter is required for the extension to operate. Supported values are:
  pap, chap, mschapv1, mschapv2, eap-md5, eap-tls, and eap-ttls. Support for
  PEAP is implemented inside the extension, but, due to a regression in the
  JRadius implementation, it is currently broken. Also, if you specify eap-ttls
  you will also need to specify the `radius-eap-ttls-inner-protocol` parameter
  in order to properly configure the protocol used inside the EAP TTLS tunnel.

`radius-key-file`
: The combination certificate and private key pair to use for TLS-based RADIUS
  protocols that require a client-side certificate. This parameter should specify
  the absolute path to the file. By default the extension will look for a file
  called `radius.key` in the `GUACAMOLE_HOME` directory.

`radius-key-type`
: The file type of the keystore specified by the `radius-key-file` parameter.
  Valid keystore types are pem, jceks, jks, and pkcs12. If not specified, this
  defaults to pkcs12, the default used by the JRadius library.

`radius-key-password`
: The password of the private key specified in the `radius-key-file` parameter.
  By default the extension will not use any password when trying to open the
  key file.

`radius-ca-file`
: The absolute path to the file that stores the certificate authority
  certificates for encrypted connections to the RADIUS server. By default a
  file with the name ca.crt in the `GUACAMOLE_HOME` directory will be used.

`radius-ca-type`
: The file type of keystore used for the certificate authority. Valid formats
  are pem, jceks, jks, and pkcs12. If not specified this defaults to pem.

`radius-ca-password`
: The password used to protect the certificate authority store, if any.  If
  unspecified the extension will attempt to read the CA store without any
  password.

`radius-trust-all`
: This parameter controls whether or not the RADIUS extension should trust all
  certificates or verify them against known good certificate authorities. Set
  to true to allow the RADIUS server to connect without validating
  certificates. The default is false, which causes certificates to be
  validated.

`radius-retries`
: The number of times the client will retry the connection to the RADIUS server
  and not receive a response before giving up. By default the client will try
  the connection at most 5 times.

`radius-timeout`
: The timeout for a RADIUS connection in seconds. By default the client will
  wait for a response from the server for at most 60 seconds.

`radius-eap-ttls-inner-protocol`
: When EAP-TTLS is used, this parameter specifies the inner (tunneled) protocol
  to use talking to the RADIUS server. It is required when the
  `radius-auth-protocol` parameter is set to eap-ttls. If the
  `radius-auth-protocol` value is set to something other than eap-ttls, this
  parameter has no effect and will be ignored. Valid options for this are any of
  the values for `radius-auth-protocol`, except for eap-ttls.

`radius-nas-ip`
: This property allows the server administrator to manually set an IP address
  that will be sent to the RADIUS server to identify this RADIUS client, known
  as the "Network Access Server" (NAS) IP address. When this property is not
  specified, the RADIUS extension attempts to automatically determine the IP
  address of the system on which Guacamole is running and uses that value.

(completing-radius-install)=

Completing the installation
---------------------------

Guacamole will only reread `guacamole.properties` and load newly-installed
extensions during startup, so your servlet container will need to be restarted
before HTTP header authentication can be used.  *Doing this will disconnect all
active users, so be sure that it is safe to do so prior to attempting
installation.* When ready, restart your servlet container and give the new
authentication a try.

