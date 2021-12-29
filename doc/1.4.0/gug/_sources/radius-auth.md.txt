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

```console
$ mvn clean package -Plgpl-extensions
[INFO] --- maven-assembly-plugin:2.5.3:single (make-source-archive) @ guacamole-client ---
[INFO] Reading assembly descriptor: project-assembly.xml
[INFO] Building tar: /home/guac/guacamole-client/target/guacamole-client-1.4.0.tar.gz
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] guacamole-common .................................. SUCCESS [6.037s]
[INFO] guacamole-ext ..................................... SUCCESS [5.382s]
[INFO] guacamole-common-js ............................... SUCCESS [0.751s]
[INFO] guacamole ......................................... SUCCESS [9.767s]
[INFO] guacamole-auth-cas ................................ SUCCESS [2.811s]
[INFO] guacamole-auth-duo ................................ SUCCESS [2.441s]
[INFO] guacamole-auth-header ............................. SUCCESS [1.875s]
[INFO] guacamole-auth-jdbc ............................... SUCCESS [0.277s]
[INFO] guacamole-auth-jdbc-base .......................... SUCCESS [2.144s]
[INFO] guacamole-auth-jdbc-mysql ......................... SUCCESS [5.637s]
[INFO] guacamole-auth-jdbc-postgresql .................... SUCCESS [5.465s]
[INFO] guacamole-auth-jdbc-sqlserver ..................... SUCCESS [5.398s]
[INFO] guacamole-auth-jdbc-dist .......................... SUCCESS [0.824s]
[INFO] guacamole-auth-ldap ............................... SUCCESS [2.743s]
[INFO] guacamole-auth-noauth ............................. SUCCESS [0.964s]
[INFO] guacamole-auth-openid ............................. SUCCESS [2.533s]
[INFO] guacamole-example ................................. SUCCESS [0.888s]
[INFO] guacamole-playback-example ........................ SUCCESS [0.628s]
[INFO] guacamole-auth-radius ............................. SUCCESS [17.729s]
[INFO] guacamole-client .................................. SUCCESS [5.645s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1:20.134s
[INFO] Finished at: Wed Jan 31 09:45:41 EST 2018
[INFO] Final Memory: 47M/749M
[INFO] ------------------------------------------------------------------------
$
```

After the build completes successfully, the extension will be in the
`extensions/guacamole-auth-radius/target/` directory, and will be called
guacamole-auth-radius-1.4.0.jar. This extension file can be copied to the
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

2. Copy `guacamole-auth-radius-1.4.0.jar` into `GUACAMOLE_HOME/extensions`.

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

