RADIUS authentication
=====================

Guacamole supports delegating authentication to a RADIUS service, such as
FreeRADIUS, to validate username and password combinations, and to support
multi-factor authentication. This authentication method must be layered on top
of some other authentication extension, such as those available from the main
project website, in order to provide access to actual connections.

```{include} include/warn-config-changes.md
```

(radius-downloading)=

Building the RADIUS authentication extension
--------------------------------------------

The RADIUS extension depends on software that is covered by a LGPL license,
which is incompatible with the Apache 2.0 license under which Guacamole is
licensed. Due to this dependency, the Guacamole project cannot distribute
binary versions of the RADIUS extension. If you want to use this extension you
will need to build the RADIUS extension from source, either by [building
guacamole-client from source using Maven](building-guacamole-client) or by
manually building the guacamole-client Docker image.

::::{tab} Native Webapp (Tomcat)

The RADIUS extension must be explicitly enabled during build time in order to
generate the binaries and resulting JAR file. This is done by adding the flag
`-Plgpl-extensions` to the Maven command line during the build, and should
result in the output below:

:::{code-block} console
:emphasize-lines: 10,19
$ mvn -Plgpl-extensions clean package
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO] 
[INFO] guacamole-client                                                   [pom]
[INFO] guacamole-common                                                   [jar]
[INFO] guacamole-ext                                                      [jar]
...
[INFO] guacamole-auth-radius                                              [jar]
...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for guacamole-client 1.6.0:
[INFO] 
[INFO] guacamole-client ................................... SUCCESS [ 12.839 s]
[INFO] guacamole-common ................................... SUCCESS [ 15.446 s]
[INFO] guacamole-ext ...................................... SUCCESS [ 19.988 s]
...
[INFO] guacamole-auth-radius .............................. SUCCESS [ 10.806 s]
...
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
`guacamole-auth-radius-1.6.0.jar`.

To install the RADIUS authentication extension, you must:

1. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

2. Copy `guacamole-auth-radius-1.6.0.jar` into `GUACAMOLE_HOME/extensions`.

3. Configure Guacamole to use RADIUS authentication, as described below.
::::

::::{tab} Container (Docker)
To build a copy of the `guacamole/guacamole` Docker image with RADIUS support,
the `-Plgpl-extensions` option must be passed to the Docker build process using
the `MAVEN_ARGUMENTS` build argument. The `-DskipTests=true` argument must also
be included, as the build otherwise performs several JavaScript unit tests that
cannot run in a containerized environment:

```console
$ docker build \
    --build-arg MAVEN_ARGUMENTS="-Plgpl-extensions -DskipTests=true" \
    -t guacamole/guacamole .
```

Once the build completes, you can use your copy of the `guacamole/guacamole`
image as you would the standard image provided with each Guacamole release.
::::

(guac-radius-config)=

Configuration
-------------

::::{tab} Native Webapp (Tomcat)


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
: The file type of the keystore used for the certificate authority. Valid
  formats are pem, jceks, jks, and pkcs12. If not specified this defaults to
  pem.

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
::::

::::{tab} Container (Docker)


`RADIUS_HOSTNAME`
: The RADIUS server to authenticate against. If not specified, localhost will
  be used.

`RADIUS_AUTH_PORT`
: The RADIUS authentication port on which the RADIUS service is is listening.
  If not specified, the default of 1812 will be used.

`RADIUS_SHARED_SECRET`
: The shared secret to use when talking to the RADIUS server. This parameter is
  required and the extension will not load if this is not specified.

`RADIUS_AUTH_PROTOCOL`
: The authentication protocol to use when talking to the RADIUS server. This
  parameter is required for the extension to operate. Supported values are:
  pap, chap, mschapv1, mschapv2, eap-md5, eap-tls, and eap-ttls. Support for
  PEAP is implemented inside the extension, but, due to a regression in the
  JRadius implementation, it is currently broken. Also, if you specify eap-ttls
  you will also need to specify the `radius-eap-ttls-inner-protocol` parameter
  in order to properly configure the protocol used inside the EAP TTLS tunnel.

`RADIUS_KEY_FILE`
: The combination certificate and private key pair to use for TLS-based RADIUS
  protocols that require a client-side certificate. This parameter should specify
  the absolute path to the file. By default the extension will look for a file
  called `radius.key` in the `GUACAMOLE_HOME` directory.

`RADIUS_KEY_TYPE`
: The file type of the keystore specified by the `radius-key-file` parameter.
  Valid keystore types are pem, jceks, jks, and pkcs12. If not specified, this
  defaults to pkcs12, the default used by the JRadius library.

`RADIUS_KEY_PASSWORD`
: The password of the private key specified in the `radius-key-file` parameter.
  By default the extension will not use any password when trying to open the
  key file.

`RADIUS_CA_FILE`
: The absolute path to the file that stores the certificate authority
  certificates for encrypted connections to the RADIUS server. By default a
  file with the name ca.crt in the `GUACAMOLE_HOME` directory will be used.

`RADIUS_CA_TYPE`
: The file type of the keystore used for the certificate authority. Valid
  formats are pem, jceks, jks, and pkcs12. If not specified this defaults to
  pem.

`RADIUS_CA_PASSWORD`
: The password used to protect the certificate authority store, if any.  If
  unspecified the extension will attempt to read the CA store without any
  password.

`RADIUS_TRUST_ALL`
: This parameter controls whether or not the RADIUS extension should trust all
  certificates or verify them against known good certificate authorities. Set
  to true to allow the RADIUS server to connect without validating
  certificates. The default is false, which causes certificates to be
  validated.

`RADIUS_RETRIES`
: The number of times the client will retry the connection to the RADIUS server
  and not receive a response before giving up. By default the client will try
  the connection at most 5 times.

`RADIUS_TIMEOUT`
: The timeout for a RADIUS connection in seconds. By default the client will
  wait for a response from the server for at most 60 seconds.

`RADIUS_EAP_TTLS_INNER_PROTOCOL`
: When EAP-TTLS is used, this parameter specifies the inner (tunneled) protocol
  to use talking to the RADIUS server. It is required when the
  `radius-auth-protocol` parameter is set to eap-ttls. If the
  `radius-auth-protocol` value is set to something other than eap-ttls, this
  parameter has no effect and will be ignored. Valid options for this are any of
  the values for `radius-auth-protocol`, except for eap-ttls.

`RADIUS_NAS_IP`
: This property allows the server administrator to manually set an IP address
  that will be sent to the RADIUS server to identify this RADIUS client, known
  as the "Network Access Server" (NAS) IP address. When this property is not
  specified, the RADIUS extension attempts to automatically determine the IP
  address of the system on which Guacamole is running and uses that value.
::::

(completing-radius-install)=

Completing installation
-----------------------

```{include} include/ext-completing.md
```
