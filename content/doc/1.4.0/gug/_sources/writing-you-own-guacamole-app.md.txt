Writing your own Guacamole application
======================================

As Guacamole is an API, one of the best ways to put Guacamole to use is by
building your own Guacamole-driven web application, integrating HTML5 remote
desktop into whatever you think needs it.

The Guacamole project provides an example of doing this called
"guacamole-example", but this example is already completed for you, and from a
quick glance at this example, it may not be obvious just how easy it is to
integrate remote access into a web application. This tutorial will walk you
through the basic steps of building an HTML5 remote desktop application using
the Guacamole API and Maven.

(basic-guacamole-architecture)=

The basics
----------

Guacamole's architecture is made up of many components, but it's actually
straightforward, especially from the perspective of the web application.

Guacamole has a proxy daemon, guacd, which handles communication using remote
desktop protocols, exposing those to whatever connects to it (in this case, the
web application) using the Guacamole protocol. From where the web application
is standing, it doesn't really matter that guacd dynamically loads protocol
plugins or that it shares a common library allowing this; all that matters is
that the web application just has to connect to port 4822 (where guacd listens
by default) and use the Guacamole protocol. The architecture will take care of
the rest.

Thankfully, the Java side of the Guacamole API provides simple classes which
already implement the Guacamole protocol with the intent of tunneling it
between guacd and the JavaScript half of your web application. A typical web
application leveraging these classes needs
only the following:

1. A class which extends `GuacamoleHTTPTunnelServlet`, providing the tunnel
   between the JavaScript client (presumably using guacamole-common-js) and
   guacd.

   `GuacamoleHTTPTunnelServlet` is an abstract class which is provided by the
   Guacamole API and already implements a fully functional, HTTP-based tunnel
   which the tunneling objects already part of guacamole-common-js are written
   to connect to. This class exists to make it easy for you to use Guacamole's
   existing and robust HTTP tunnel implementation.

   If you want to not use this class and instead use your own tunneling
   mechanism, perhaps WebSocket, this is fine; the JavaScript object mentioned
   above implements a common interface which you can also implement, and the
   Guacamole JavaScript client which is also part of guacamole-common-js will
   happily use your implementation as long as it provides that interface.

2. A web page which includes JavaScript files from guacamole-common-js and uses
   the client and tunnel objects to connect back to the web application.

   The JavaScript API provided by the Guacamole project includes a full
   implementation of the Guacamole protocol as a client, implementations of
   HTTP and WebSocket-based tunnels, and mouse/keyboard/touch input
   abstraction. Again, as the Guacamole protocol and all parts of the
   architecture are documented here, you don't absolutely need to use these
   objects, but it will make your life easier. Mouse and keyboard support in
   JavaScript is finicky business, and the Guacamole client provided is
   well-known to work with other components in the API, being the official
   client of the project.

That's really all there is to it.

If you want authentication, the place to implement that would be in your
extended version of `GuacamoleHTTPTunnelServlet`; this is what the Guacamole
web application does. Besides authentication, there are many other things you
could wrap around your remote desktop application, but ultimately the base of
all this is simple: you have a tunnel which allows the JavaScript client to
communicate with guacd, and you have the JavaScript client itself, with the
hard part already provided within guacamole-common-js.

(web-app-skeleton)=

Web application skeleton
------------------------

As with most tutorials, this tutorial begins with creating a project skeleton
that establishes a minimal base for the tutorial to enhance in subsequent
steps.

This tutorial will use Maven, which is the same build system used by the
upstream Guacamole project. As the Guacamole project has a Maven repository for
both the Java and JavaScript APIs, writing a Guacamole-based application using
Maven is much easier; Maven will download and use the Guacamole API
automatically.

### `pom.xml`

All Maven projects must have a project descriptor, the `pom.xml` file, in the
root directory of the project. This file describes project dependencies and
specific build requirements. Unlike other build tools like Apache Ant or GNU
Autotools, Maven chooses convention over configuration: files within the
project must be placed in specific locations, and the project dependencies must
be fully described in the pom.xml. If this is done, the build will be handled
automatically.

The basis of this Guacamole-driven web application will be a simple HTML file
which will ultimately become the client. While the finished product will have
an HTTP tunnel written in Java, we don't need this yet for our skeleton. We
will create a very basic, barebones Maven project containing only `index.html`
and a web application descriptor file, `web.xml`. Once these files are in
place, the project can be packaged into a `.war` file which can be deployed to
your servlet container of choice (such as Apache Tomcat).

As this skeleton will contain no Java code, it has no dependencies, and
no build requirements beyond the metadata common to any Maven project.
The `pom.xml` is thus very simple for the time being:
i
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
                             http://maven.apache.org/maven-v4_0_0.xsd">

    <modelVersion>4.0.0</modelVersion>
    <groupId>org.apache.guacamole</groupId>
    <artifactId>guacamole-tutorial</artifactId>
    <packaging>war</packaging>
    <version>1.4.0</version>
    <name>guacamole-tutorial</name>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

</project>
```

### `WEB-INF/web.xml`

Before the project will build, there needs to be a web application deployment
descriptor, `web.xml`. This file is required by the Java EE standard for
building the `.war` file which will contain the web application, and will be
read by the servlet container when the application is actually deployed. For
Maven to find and use this file when building the `.war`, it must be placed in
the `src/main/webapp/WEB-INF/` directory.

```xml
<?xml version="1.0" encoding="UTF-8"?>

<web-app version="2.5"
    xmlns="http://java.sun.com/xml/ns/javaee"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://java.sun.com/xml/ns/javaee 
                        http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd">

    <!-- Basic config -->
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
    </welcome-file-list>

</web-app>
```

### `index.html`

With the `web.xml` file in place and the skeleton `pom.xml` written, the web
application will now build successfully. However, as the `web.xml` refers to a
"welcome file" called `index.html` (which will ultimately contain our client),
we need to put this in place so the servlet container will have something to
serve. This file, as well as any other future static files, belongs within
`src/main/webapp`.

For now, this file can contain anything, since the other parts of our
Guacamole-driven web application are not written yet. It is a placeholder which
we will replace later:

```html
<!DOCTYPE HTML>
<html>

    <head>
        <title>Guacamole Tutorial</title>
    </head>

    <body>
        <p>Hello World</p>
    </body>

</html>
```

### Building the skeleton

Once all three of the above files are in place, the web application will build,
and can even be deployed to your servlet container. It won't do anything yet
other than serve the `index.html` file, but it's good to at least try building
the web application to make sure nothing is missing and all steps were followed
correctly before proceeding:

```console
$ mvn package
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Building guacamole-tutorial
[INFO]    task-segment: [package]
[INFO] ------------------------------------------------------------------------
...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESSFUL
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 4 seconds
[INFO] Finished at: Fri Jan 11 13:04:11 PST 2013
[INFO] Final Memory: 18M/128M
[INFO] ------------------------------------------------------------------------
$
```

Assuming you see the "`BUILD SUCCESSFUL`" message when you build the web
application, there will be a new file, `target/guacamole-tutorial-1.4.0.war`,
which can be deployed to your servlet container and tested. If you changed the
name or version of the project in the `pom.xml` file, the name of this new
`.war` file will be different, but it can still be found within `target/`.

(guacamole-skeleton)=

Adding Guacamole
----------------

Once we have a functional web application built, the next step is to actually
add the references to the Guacamole API and integrate a Guacamole client into
the application.

(adding-guac-to-pom)=

### Updating `pom.xml`

Now that we're adding Guacamole components to our project, we need to modify
`pom.xml` to specify which components are being used, and where they can be
obtained. With this information in place, Maven will automatically resolve
dependencies and download them as necessary during the build.

Regarding the build process itself, there are two main changes: we are now
going to be using Java, and we need the JavaScript files from
guacamole-common-js included automatically inside the `.war`.

Guacamole requires at least Java 8, thus we must add a section to the
`pom.xml` which describes the source and target Java versions:

```xml
    ...

    <build>
        <plugins>

            <!-- Compile using Java 8 -->
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

    ...
```

Including the JavaScript files from an external project like
guacamole-common-js requires using a feature of the maven war plugin called
overlays. To add an overlay containing guacamole-common-js, we add a section
describing the configuration of the Maven war plugin, listing
guacamole-common-js as an overlay:

```xml
    ...

    <build>
        <plugins>

            ...

            <!-- Overlay guacamole-common-js (zip) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>2.6</version>
                <configuration>
                    <overlays>
                        <overlay>
                            <groupId>org.apache.guacamole</groupId>
                            <artifactId>guacamole-common-js</artifactId>
                            <type>zip</type>
                        </overlay>
                    </overlays>
                </configuration>
            </plugin>

        </plugins>

    </build>

    ...
```

With the build now configured, we still need to add dependencies and list the
repositories those dependencies can be downloaded from.

As this is a web application which will use the Java Servlet API, we must
explicitly include this as a dependency, as well as the Guacamole Java and
JavaScript APIs:

```xml
    ...

    <dependencies>

        <!-- Servlet API -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>servlet-api</artifactId>
            <version>2.5</version>
            <scope>provided</scope>
        </dependency>

        <!-- Main Guacamole library -->
        <dependency>
            <groupId>org.apache.guacamole</groupId>
            <artifactId>guacamole-common</artifactId>
            <version>1.4.0</version>
            <scope>compile</scope>
        </dependency>

        <!-- Guacamole JavaScript library -->
        <dependency>
            <groupId>org.apache.guacamole</groupId>
            <artifactId>guacamole-common-js</artifactId>
            <version>1.4.0</version>
            <type>zip</type>
            <scope>runtime</scope>
        </dependency>

    </dependencies>

    ...
```

The Java Servlet API will be provided by your servlet container, so Maven does
not need to download it during the build, and it need not exist in any Maven
repository.

With these changes, the web application will still build at this point, even
though no Java code has been written yet. You may wish to verify that
everything still works.

If the `pom.xml` was updated properly as described above, the web application
should build successfully, and the Guacamole JavaScript API should be
accessible in the `guacamole-common-js/` subdirectory of your web application
after it is deployed. A quick check that you can access
`/guacamole-tutorial-1.4.0/guacamole-common-js/all.min.js` is probably worth
the effort.

(simple-tunnel)=

### The simplest tunnel possible

As with the other tutorials in this book, we will keep this simple for the sake
of demonstrating the principles behind a Guacamole-based web application, and
to give developers a good idea of where to start looking when it's time to
consult the API documentation.

It is the duty of the class extending `GuacamoleHTTPTunnelServlet` to implement
a function called `doConnect()`. This is the only function required to be
implemented, and in general it is the only function you should implement; the
other functions involved are already optimized for tunneling the Guacamole
protocol.

The `doConnect()` function returns a `GuacamoleTunnel`, which provides a
persistent communication channel for `GuacamoleHTTPTunnelServlet` to use when
talking with guacd and initiating a connection with some arbitrary remote
desktop using some arbitrary remote desktop protocol.  In our simple tunnel,
this configuration will be hard-coded, and no authentication will be attempted.
Any user accessing this web application will be immediately given a functional
remote desktop, no questions asked.

Create a new file, `TutorialGuacamoleTunnelServlet.java`, defining a basic
implementation of a tunnel servlet class:

```java
package org.apache.guacamole.net.example;

import javax.servlet.http.HttpServletRequest;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.GuacamoleSocket;
import org.apache.guacamole.net.GuacamoleTunnel;
import org.apache.guacamole.net.InetGuacamoleSocket;
import org.apache.guacamole.net.SimpleGuacamoleTunnel;
import org.apache.guacamole.protocol.ConfiguredGuacamoleSocket;
import org.apache.guacamole.protocol.GuacamoleConfiguration;
import org.apache.guacamole.servlet.GuacamoleHTTPTunnelServlet;

public class TutorialGuacamoleTunnelServlet
    extends GuacamoleHTTPTunnelServlet {

    @Override
    protected GuacamoleTunnel doConnect(HttpServletRequest request)
        throws GuacamoleException {

        // Create our configuration
        GuacamoleConfiguration config = new GuacamoleConfiguration();
        config.setProtocol("vnc");
        config.setParameter("hostname", "localhost");
        config.setParameter("port", "5901");
        config.setParameter("password", "potato");

        // Connect to guacd - everything is hard-coded here.
        GuacamoleSocket socket = new ConfiguredGuacamoleSocket(
                new InetGuacamoleSocket("localhost", 4822),
                config
        );

        // Return a new tunnel which uses the connected socket
        return new SimpleGuacamoleTunnel(socket);;

    }

}
```

Place this file in the `src/main/java/org/apache/guacamole/net/example`
subdirectory of the project. The initial part of this subdirectory,
`src/main/java`, is the path required by Maven, while the rest is the directory
required by Java based on the package associated with the class.

Once the class defining our tunnel is created, it must be added to the
`web.xml` such that the servlet container knows which URL maps to it.  This URL
will later be given to the JavaScript client to establish the connection back
to the Guacamole server:

```xml
    ...

    <!-- Guacamole Tunnel Servlet -->
    <servlet>
        <description>Tunnel servlet.</description>
        <servlet-name>Tunnel</servlet-name>
        <servlet-class>
            org.apache.guacamole.net.example.TutorialGuacamoleTunnelServlet
        </servlet-class>
    </servlet>

    <servlet-mapping>
        <servlet-name>Tunnel</servlet-name>
        <url-pattern>/tunnel</url-pattern>
    </servlet-mapping>

    ...
```

The first section assigns a unique name, "Tunnel", to the servlet class we just
defined. The second section maps the servlet class by it's servlet name
("Tunnel") to the URL we wish to use when making HTTP requests to the servlet:
`/tunnel`. This URL is relative to the context root of the web application. In
the case of this web application, the final absolute URL will be
`/guacamole-tutorial-1.4.0/tunnel`.

(simple-client)=

### Adding the client

As the Guacamole JavaScript API already provides functional client and tunnel
implementations, as well as mouse and keyboard input objects, the coding
required for the "web" side of the web application is very minimal.

We must create a `Guacamole.HTTPTunnel`, connect it to our
previously-implemented tunnel servlet, and pass that tunnel to a new
`Guacamole.Client`. Once that is done, and the `connect()` function of the
client is called, communication will immediately ensue, and your remote desktop
will be visible:

```html
    ...
    <body>

        <!-- Guacamole -->
        <script type="text/javascript"
            src="guacamole-common-js/all.min.js"></script>

        <!-- Display -->
        <div id="display"></div>

        <!-- Init -->
        <script type="text/javascript"> /* <![CDATA[ */

            // Get display div from document
            var display = document.getElementById("display");

            // Instantiate client, using an HTTP tunnel for communications.
            var guac = new Guacamole.Client(
                new Guacamole.HTTPTunnel("tunnel")
            );

            // Add client to display div
            display.appendChild(guac.getDisplay().getElement());
            
            // Error handler
            guac.onerror = function(error) {
                alert(error);
            };

            // Connect
            guac.connect();

            // Disconnect on close
            window.onunload = function() {
                guac.disconnect();
            }

        /* ]]> */ </script>

    </body>
    ...
```

If you build and deploy the web application now, it will work, but mouse and
keyboard input will not. This is because input is not implemented by the client
directly. The `Guacamole.Client` object only decodes the Guacamole protocol and
handles the display, providing an element which you can add manually to the
DOM. While it will also send keyboard and mouse events for you, you need to
call the respective functions manually. The Guacamole API provides keyboard and
mouse abstraction objects which make this easy.

We need only create a `Guacamole.Mouse` and `Guacamole.Keyboard`, and add event
handlers to handle their corresponding input events, calling whichever function
of the Guacamole client is appropriate to send the input event through the
tunnel to guacd:

```html
        ...

        <!-- Init -->
        <script type="text/javascript"> /* <![CDATA[ */

            ...

            // Mouse
            var mouse = new Guacamole.Mouse(guac.getDisplay().getElement());

            mouse.onmousedown = 
            mouse.onmouseup   =
            mouse.onmousemove = function(mouseState) {
                guac.sendMouseState(mouseState);
            };

            // Keyboard
            var keyboard = new Guacamole.Keyboard(document);

            keyboard.onkeydown = function (keysym) {
                guac.sendKeyEvent(1, keysym);
            };

            keyboard.onkeyup = function (keysym) {
                guac.sendKeyEvent(0, keysym);
            };

        /* ]]> */ </script>

        ...
```

(next-steps)=

Where to go from here
---------------------

At this point, we now have a fully functional Guacamole-based web application.
This web application inherits all the core functionality present in the
official Guacamole web application, including sound and video, without very
much coding.

Extending this application to provide authentication, multiple connections per
user, or a spiffy interface which is compatible with mobile is not too much of
a stretch. This is exactly how the Guacamole web application is written.
Integrating Guacamole into an existing application would be similar.

