Event listeners
===============

Guacamole supports the delivery of event notifications to custom extensions.
Developers can use listener extensions to integrate custom handling of events
such as successful and failed authentications, and requests to connect and
disconnect tunnels to desktop environments.

A listener extension could be used, for example, to record authentication
attempts in an external database for security auditing or alerting. By
listening to tunnel lifecycle events, a listener extension could be used to
help coordinate startup and shutdown of machine resources; particularly useful
in cloud environments where minimizing running-but-idle resources is an
important cost savings measure.

For certain *vetoable* events, an event listener can even influence Guacamole's
behavior. For example, a listener can veto a successful authentication,
effectively causing the authentication to be considered failed. Similarly, a
listener can veto a tunnel connection, effectively preventing the tunnel from
being connected to a virtual desktop resource.

Custom event listeners are packaged using the same extension mechanism used for
custom authentication providers. A single listener extension can include any
number of classes that implement the listener interface.  A single extension
module can also include any combination of authentication providers and
listeners, so developers can easily combine authentication providers with
listeners designed to support them.

To demonstrate the principles involved in receiving Guacamole event
notifications, we will implement a simple listener extension that logs
authentication events. While our approach simply writes event details to the
same log used by the Guacamole web application, a listener could process these
events in arbitrary ways, limited only by the imagination and ingenuity of the
developer.

(custom-event-listener-skeleton)=

A Guacamole listener extension skeleton
---------------------------------------

For simplicity's sake, and because this is how things are done upstream in the
Guacamole project, we will use Maven to build our extension.

The bare minimum required for a Guacamole listener extension is a `pom.xml`
file listing guacamole-ext as a dependency, a single `.java` file implementing
our stub of a listener, and a `guac-manifest.json` file describing the
extension and pointing to our listener class.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                        http://maven.apache.org/maven-v4_0_0.xsd">

    <modelVersion>4.0.0</modelVersion>
    <groupId>org.apache.guacamole</groupId>
    <artifactId>guacamole-listener-tutorial</artifactId>
    <packaging>jar</packaging>
    <version>1.4.0</version>
    <name>guacamole-listener-tutorial</name>

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

        <!-- Slf4j API -->
        <!-- This is needed only if your listener wants to 
                write to the Guacamole web application log -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.7</version>
            <scope>provided</scope>
        </dependency>

    </dependencies>

</project>
```

Naturally, we need the actual listener extension skeleton code. While you can
put this in whatever file and package you want, for the sake of this tutorial,
we will assume you are using `org.apache.guacamole.event.TutorialListener`.

For now, we won't actually do anything other than log the fact that an event
notification was received. At this point, we're just creating the skeleton for
our listener extension.

```java
package org.apache.guacamole.event;

import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.event.listener.Listener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A Listener implementation intended to demonstrate basic use
 * of Guacamole's listener extension API.
 */
public class TutorialListener implements Listener {

    private static final Logger logger = 
         LoggerFactory.getLogger(TutorialListener.class);

    @Override
    public void handleEvent(Object event) throws GuacamoleException {
        logger.info("received Guacamole event notification");
    }

}
```

To conform with Maven, this skeleton file must be placed within
`src/main/java/org/apache/guacamole/event` as `TutorialListener.java`.

As you can see, implementing a listener is quite simple. There is a single
`Listener` interface to implement. All Guacamole event notifications will be
delivered to your code by invoking the handleEvent method. We will see shortly
how to use the passed event object to get the details of the event itself.

The only remaining piece for the overall skeleton to be complete is a
`guac-manifest.json` file. *This file is absolutely required for all Guacamole
extensions.* The `guac-manifest.json` format is described in more detail in
[](guacamole-ext). It provides for quite a few properties, but for our listener
extension we are mainly interested in the Guacamole version sanity check (to
make sure an extension built for the API of Guacamole version X is not
accidentally used against version Y) and telling Guacamole where to find our
listener class.

The Guacamole extension format requires that `guac-manifest.json` be placed in
the root directory of the extension `.jar` file. To accomplish this with Maven,
we place it within the `src/main/resources` directory. Maven will automatically
pick it up during the build and include it within the `.jar`.

```json
{

    "guacamoleVersion" : "1.4.0",

    "name"      : "Tutorial Listener Extension",
    "namespace" : "guac-listener-tutorial",

    "listeners" : [
        "org.apache.guacamole.event.TutorialListener"
    ]

}
```

(custom-listener-building)=

Building the extension
----------------------

Once all three of the above files are in place, the extension should build
successfully even though it is just a skeleton at this point.

```console
$ mvn package
[INFO] Scanning for projects...
[INFO] ---------------------------------------------------------------
[INFO] Building guacamole-listener-tutorial 1.4.0
[INFO] ---------------------------------------------------------------
...
[INFO] ---------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ---------------------------------------------------------------
[INFO] Total time: 1.297 s
[INFO] Finished at: 2017-10-08T13:12:39-04:00
[INFO] Final Memory: 19M/306M
[INFO] ---------------------------------------------------------------
$
```

Assuming you see the "`BUILD SUCCESS`" message when you build the extension,
there will be a new file, `target/guacamole-listener-tutorial-1.4.0.jar`, which
can be installed within Guacamole (see [](custom-listener-installing) at the
end of this chapter).  It should log event notifications that occur during, for
example, authentication attempts. If you changed the name or version of the
project in the `pom.xml` file, the name of this new `.jar` file will be
different, but it can still be found within `target/`.

(custom-listener-event-handling)=

Handling events
---------------

The Guacamole `Listener` interface represents a low-level event handling API. A
listener is notified of every event generated by Guacamole. The listener must
examine the event type to determine whether the event is of interest, and if so
to dispatch the event to the appropriate entry point.

The event types that can be produced by Guacamole are described in the
`org.apache.guacamole.net.event` package of the guacamole-ext API. In this
package you will find several concrete event types as well as interfaces that
describe common characteristics of certain of event types. You can use any of
these types to distinguish the events received by your listener, and to examine
properties of an event of a given type.

Suppose we wish to log authentication success and failure events, while
ignoring all other event types. The `AuthenticationSuccessEvent` and
`AuthenticationFailureEvent` types are used to notify a listener of
authentication events. We can simply check whether a received event is of one
of these types and, if so, log an appropriate message.

```java
package org.apache.guacamole.event;

import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.event.AuthenticationFailureEvent;
import org.apache.guacamole.net.event.AuthenticationSuccessEvent;
import org.apache.guacamole.net.event.listener.Listener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A Listener that logs authentication success and failure events.
 */
public class TutorialListener implements Listener {

    private static final Logger logger = 
        LoggerFactory.getLogger(TutorialListener.class);

    @Override
    public void handleEvent(Object event) throws GuacamoleException {

        if (event instanceof AuthenticationSuccessEvent) {
            logger.info("successful authentication for user {}", 
                ((AuthenticationSuccessEvent) event)
                    .getCredentials().getUsername());
        }
        else if (event instanceof AuthenticationFailureEvent) {
            logger.info("failed authentication for user {}", 
                ((AuthenticationFailureEvent) event)
                    .getCredentials().getUsername());
        }
    }

}
```

In our example, we use `instanceof` to check for the two event types of
interest to our listener. Once we have identified an event of interest, we can
safely cast the event type to access properties of the event.

The extension is now complete and can be built as described earlier in
[](custom-listener-building) and installed as described below in
[](custom-listener-installing).

(custom-listener-veto)=

Influencing Guacamole by event veto
-----------------------------------

An implementation of the handleEvent method is permitted to throw any
`GuacamoleException`. For certain *vetoable* event types, throwing a
`GuacamoleException` serves to effectively veto the action that resulted in the
event notification. See the API documentation for guacamole-ext to learn more
about vetoable event types.

As an (admittedly contrived) example, suppose we want to prevent a user named
"guacadmin" from accessing Guacamole. For whatever reason, we don't wish to
remove or disable the auth database entry for this user.  In this case we can
use a listener to block this user, preventing access to Guacamole. In the
listener, when we get an `AuthenticationSuccessEvent` we can check to see if
the user is "guacadmin" and, if so, throw an exception to prevent this user
from logging in to Guacamole.

```java
package org.apache.guacamole.event;

import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.GuacamoleSecurityException;
import org.apache.guacamole.net.event.AuthenticationFailureEvent;
import org.apache.guacamole.net.event.AuthenticationSuccessEvent;
import org.apache.guacamole.net.event.listener.Listener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A Listener that logs authentication success and failure events
 * and prevents the "guacadmin" user from logging in by throwing
 * a GuacamoleSecurityException.
 */
public class TutorialListener implements Listener {

    private static final Logger logger = 
        LoggerFactory.getLogger(TutorialListener.class);

    @Override
    public void handleEvent(Object event) throws GuacamoleException {

        if (event instanceof AuthenticationSuccessEvent) {
          final String username = ((AuthenticationSuccessEvent) event)
              .getCredentials().getUsername();

          if ("guacadmin".equals(username)) {
            logger.warn("user {} has been blocked", username);
            throw new GuacamoleSecurityException(
                "User '" + username + "' is currently blocked");
          }

          logger.info("successful authentication for user {}", username);
        }
        else if (event instanceof AuthenticationFailureEvent) {
            logger.info("failed authentication for user {}", 
                ((AuthenticationFailureEvent) event)
                    .getCredentials().getUsername());
        }
    }

}
```

If our Guacamole user database contains a user named "guacadmin", and we build
and install this listener extension, we will find that an attempt to log in as
this user now results in a message in the UI indicating that the user is
blocked. If we examine the Guacamole log, we will see the message indicating
that the user was blocked. Because the successful authentication was vetoed,
Guacamole sends a subsequent authentication failure notification, which we see
logged as well.

(custom-listener-installing)=

Installing the extension
------------------------

Guacamole extensions are self-contained `.jar` files which are installed by
being placed within `GUACAMOLE_HOME/extensions`, and this extension is no
different. As described in [](configuring-guacamole), `GUACAMOLE_HOME` is a
placeholder used to refer to the directory that Guacamole uses to locate its
configuration files and extensions. Typically, this will be the `.guacamole`
directory within the home directory of the user running Tomcat.

To install your extension, copy the
`target/guacamole-listener-tutorial-1.4.0.jar` file into
`GUACAMOLE_HOME/extensions` and restart Tomcat. Guacamole will automatically
load your extension, logging an informative message that it has done so:

```
Extension "Tutorial Listener Extension" loaded.
```

