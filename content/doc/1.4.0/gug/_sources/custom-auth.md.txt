Custom authentication
=====================

Guacamole's authentication layer is designed to be extendable such that users
can integrate Guacamole into existing authentication systems without having to
resort to writing their own web application around the Guacamole API.

The web application comes with a default authentication mechanism which uses an
XML file to associate users with connections. Extensions for Guacamole that
provide LDAP-based authentication or database-based authentication have also
been developed.

To demonstrate the principles involved, we will implement a very simple
authentication extension which associates a single user/password pair with a
single connection, with all this information saved in properties inside the
`guacamole.properties` file.

In general, all other authentication extensions for Guacamole will use the
principles demonstrated here. This tutorial demonstrates the simplest way to
create an authentication extension for Guacamole - an authentication extension
that does not support management of users and connections via the web
interface.

(custom-auth-model)=

Guacamole's authentication model
--------------------------------

When you view any page in Guacamole, whether that be the login screen or the
client interface, the page makes an authentication attempt with the web
application, sending all available credentials. After entering your username
and password, the exact same process occurs, except the web application
receives the username and password as well.

The web application handles this authentication attempt by collecting all
credentials available and passing them to designated classes called
"authentication providers". Given the set of credentials, authentication
providers return a context object that provides restricted access to other
users and connections, if any.

(custom-auth-skeleton)=

A Guacamole extension skeleton
------------------------------

For simplicity's sake, and because this is how things are done upstream in the
Guacamole project, we will use Maven to build our extension.

The bare minimum required for a Guacamole authentication extension is a
`pom.xml` file listing guacamole-ext as a dependency, a single .java file
implementing our stub of an authentication provider, and a `guac-manifest.json`
file describing the extension and pointing to our authentication provider
class.

In our stub, we won't actually do any authentication yet; we'll just
universally reject all authentication attempts by returning `null` for any
credentials given. You can verify that this is what happens by checking the
server logs.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                        http://maven.apache.org/maven-v4_0_0.xsd">

    <modelVersion>4.0.0</modelVersion>
    <groupId>org.apache.guacamole</groupId>
    <artifactId>guacamole-auth-tutorial</artifactId>
    <packaging>jar</packaging>
    <version>1.4.0</version>
    <name>guacamole-auth-tutorial</name>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <build>
        <plugins>

            <!-- Written for Java 8 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.3</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>

        </plugins>
    </build>

    <dependencies>

        <!-- Guacamole Extension API -->
        <dependency>
            <groupId>org.apache.guacamole</groupId>
            <artifactId>guacamole-ext</artifactId>
            <version>1.4.0</version>
            <scope>provided</scope>
        </dependency>

    </dependencies>

</project>
```

We won't need to update this `pom.xml` throughout the rest of the tutorial.
Even after adding new files, Maven will just find them and compile as
necessary.

Naturally, we need the actual authentication extension skeleton code.  While
you can put this in whatever file and package you want, for the sake of this
tutorial, we will assume you are using
`org.apache.guacamole.auth.TutorialAuthenticationProvider`.

```java
package org.apache.guacamole.auth;

import java.util.Map;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.auth.simple.SimpleAuthenticationProvider;
import org.apache.guacamole.net.auth.Credentials;
import org.apache.guacamole.protocol.GuacamoleConfiguration;

/**
 * Authentication provider implementation intended to demonstrate basic use
 * of Guacamole's extension API. The credentials and connection information for
 * a single user are stored directly in guacamole.properties.
 */
public class TutorialAuthenticationProvider extends SimpleAuthenticationProvider {

    @Override
    public String getIdentifier() {
        return "tutorial";
    }

    @Override
    public Map<String, GuacamoleConfiguration>
        getAuthorizedConfigurations(Credentials credentials)
        throws GuacamoleException {

        // Do nothing ... yet
        return null;        

    }

}
```

To conform with Maven, this skeleton file must be placed within
`src/main/java/org/apache/guacamole/auth` as
`TutorialAuthenticationProvider.java`.

Notice how simple the authentication provider is. The
`SimpleAuthenticationProvider` base class simplifies the
`AuthenticationProvider` interface, requiring nothing more than a unique
identifier (we will use "tutorial") and a single getAuthorizedConfigurations()
implementation, which must return a `Map` of `GuacamoleConfiguration` each
associated with some arbitrary unique ID. This unique ID will be presented to
the user in the connection list after they log in.

For now, `getAuthorizedConfigurations()` will just return `null`. This will
cause Guacamole to report an invalid login for every attempt. Note that there
is a difference in semantics between returning an empty map and returning
`null`, as the former indicates the credentials are authorized but simply have
no associated configurations, while the latter indicates the credentials are
not authorized at all.

The only remaining piece for the overall skeleton to be complete is a
`guac-manifest.json` file. *This file is absolutely required for all Guacamole
extensions.* The `guac-manifest.json` format is described in more detail in
[](guacamole-ext). It provides for quite a few properties, but for our
authentication extension we are mainly interested in the Guacamole version
sanity check (to make sure an extension built for the API of Guacamole version
X is not accidentally used against version Y) and telling Guacamole where to
find our authentication provider class.

The Guacamole extension format requires that `guac-manifest.json` be placed in
the root directory of the extension `.jar` file. To accomplish this with Maven,
we place it within the `src/main/resources` directory. Maven will automatically
pick it up during the build and include it within the `.jar`.

```json
{

    "guacamoleVersion" : "1.4.0",

    "name"      : "Tutorial Authentication Extension",
    "namespace" : "guac-auth-tutorial",

    "authProviders" : [
        "org.apache.guacamole.auth.TutorialAuthenticationProvider"
    ]

}
```

(custom-auth-building)=

Building the extension
----------------------

Once all three of the above files are in place, the extension will build, and
can even be installed within Guacamole (see [](custom-auth-installing) at the
end of this chapter), even though it is just a skeleton at this point. It won't
do anything yet other than reject all authentication attempts, but it's good to
at least try building the extension to make sure nothing is missing and that
all steps have been followed correctly so far:

```console
$ mvn package
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Building guacamole-auth-tutorial 1.4.0
[INFO] ------------------------------------------------------------------------
...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.345 s
[INFO] Finished at: 2015-12-16T13:39:00-08:00
[INFO] Final Memory: 14M/138M
[INFO] ------------------------------------------------------------------------
$
```

Assuming you see the "`BUILD SUCCESS`" message when you build the extension,
there will be a new file, `target/guacamole-auth-tutorial-1.4.0.jar`, which can
be installed within Guacamole and tested. If you changed the name or version of
the project in the `pom.xml` file, the name of this new `.jar` file will be
different, but it can still be found within `target/`.

(custom-auth-config)=

Configuration and authentication
--------------------------------

Once we receive credentials, we need to validate those credentials against the
associated properties in `guacamole.properties` (our source of authentication
information for the sake of this tutorial).

We will define four properties:

`tutorial-user`
: The name of the only user we accept.

`tutorial-password`
: The password we require for the user specified to be authenticated.

`tutorial-protocol`
: The protocol of the configuration this user is authorized to use, which
  will be sent to guacd when the user logs in and selects their connection.

`tutorial-parameters`
: A comma-delimited list of `name=value` pairs. For the sake of simplicity,
  we'll assume there will never be any commas in the values.

If the username and password match what is stored in the file, we read the
configuration information, store it in a `GuacamoleConfiguration`, and return
the configuration within a set, telling Guacamole that this user is authorized
but only to access the configurations returned.

Upstream, we always place the properties of authentication providers in their
own class, and so we will also do that here in this tutorial, as it keeps
things organized.

```java
package org.apache.guacamole.auth;

import org.apache.guacamole.properties.StringGuacamoleProperty;

/**
 * Utility class containing all properties used by the custom authentication
 * tutorial. The properties defined here must be specified within
 * guacamole.properties to configure the tutorial authentication provider.
 */
public class TutorialGuacamoleProperties {

    /**
     * This class should not be instantiated.
     */
    private TutorialGuacamoleProperties() {}

    /**
     * The only user to allow.
     */
    public static final StringGuacamoleProperty TUTORIAL_USER = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-user"; }

    };

    /**
     * The password required for the specified user.
     */
    public static final StringGuacamoleProperty TUTORIAL_PASSWORD = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-password"; }

    };


    /**
     * The protocol to use when connecting.
     */
    public static final StringGuacamoleProperty TUTORIAL_PROTOCOL = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-protocol"; }

    };


    /**
     * All parameters associated with the connection, as a comma-delimited
     * list of name="value" 
     */
    public static final StringGuacamoleProperty TUTORIAL_PARAMETERS = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-parameters"; }

    };

}
```

Normally, we would define a new type of `GuacamoleProperty` to handle the
parsing of the parameters required by `TUTORIAL_PARAMETERS`, but for the sake
of simplicity, parsing of this parameter will be embedded in the authentication
function later.

You will need to modify your existing `guacamole.properties` file, adding each
of the above properties to describe one of your available connections.

```
# Username and password
tutorial-user:     tutorial
tutorial-password: password

# Connection information
tutorial-protocol:   vnc
tutorial-parameters: hostname=localhost, port=5900
```

Once these properties and their accessor class are in place, it's simple enough
to read the properties within `getAuthorizedConfigurations()` and authenticate
the user based on their username and password.

```java
@Override
public Map<String, GuacamoleConfiguration>
    getAuthorizedConfigurations(Credentials credentials)
    throws GuacamoleException {

    // Get the Guacamole server environment
    Environment environment = new LocalEnvironment();

    // Get username from guacamole.properties
    String username = environment.getRequiredProperty(
        TutorialGuacamoleProperties.TUTORIAL_USER
    );      

    // If wrong username, fail
    if (!username.equals(credentials.getUsername()))
        return null;

    // Get password from guacamole.properties
    String password = environment.getRequiredProperty(
        TutorialGuacamoleProperties.TUTORIAL_PASSWORD
    );      

    // If wrong password, fail
    if (!password.equals(credentials.getPassword()))
        return null;

    // Successful login. Return configurations (STUB)
    return new HashMap<String, GuacamoleConfiguration>();

}
```

As is, the authentication provider will work in its current state in that the
correct username and password will authenticate the user, while an incorrect
username or password will not, but we still aren't returning an actual map of
configurations. We need to construct the configuration based on the properties
in the `guacamole.properties` file after the user has been authenticated, and
return that configuration to the web application.

(custom-auth-more-config)=

Parsing the configuration
-------------------------

The only remaining task before we have a fully-functioning authentication
provider is to actually parse the configuration from the `guacamole.properties`
file.

```java
@Override
public Map<String, GuacamoleConfiguration>
    getAuthorizedConfigurations(Credentials credentials)
    throws GuacamoleException {

    // Get the Guacamole server environment
    Environment environment = new LocalEnvironment();

    // Get username from guacamole.properties
    String username = environment.getRequiredProperty(
        TutorialGuacamoleProperties.TUTORIAL_USER
    );      

    // If wrong username, fail
    if (!username.equals(credentials.getUsername()))
        return null;

    // Get password from guacamole.properties
    String password = environment.getRequiredProperty(
        TutorialGuacamoleProperties.TUTORIAL_PASSWORD
    );      

    // If wrong password, fail
    if (!password.equals(credentials.getPassword()))
        return null;

    // Successful login. Return configurations.
    Map<String, GuacamoleConfiguration> configs = 
        new HashMap<String, GuacamoleConfiguration>();

    // Create new configuration
    GuacamoleConfiguration config = new GuacamoleConfiguration();

    // Set protocol specified in properties
    config.setProtocol(environment.getRequiredProperty(
        TutorialGuacamoleProperties.TUTORIAL_PROTOCOL
    ));

    // Set all parameters, splitting at commas
    for (String parameterValue : environment.getRequiredProperty(
        TutorialGuacamoleProperties.TUTORIAL_PARAMETERS
    ).split(",\\s*")) {

        // Find the equals sign
        int equals = parameterValue.indexOf('=');
        if (equals == -1)
            throw new GuacamoleServerException("Required equals sign missing");

        // Get name and value from parameter string
        String name = parameterValue.substring(0, equals);
        String value = parameterValue.substring(equals+1);

        // Set parameter as specified
        config.setParameter(name, value);

    }

    configs.put("Tutorial Connection", config);
    return configs;

}
```

The extension is now complete and can be built as described earlier in
[](custom-auth-building).

(custom-auth-installing)=

Installing the extension
------------------------

Guacamole extensions are self-contained `.jar` files which are installed by
being placed within `GUACAMOLE_HOME/extensions`, and this extension is no
different. As described in [](configuring-guacamole), `GUACAMOLE_HOME` is a
placeholder used to refer to the directory that Guacamole uses to locate its
configuration files and extensions. Typically, this will be the `.guacamole`
directory within the home directory of the user running Tomcat.

To install your extension, ensure that the required properties have been added
to your `guacamole.properties`, copy the
`target/guacamole-auth-tutorial-1.4.0.jar` file into
`GUACAMOLE_HOME/extensions` and restart Tomcat. Guacamole will automatically
load your extension, logging an informative message that it has done so:

```
Extension "Tutorial Authentication Extension" loaded.
```

