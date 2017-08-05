---
layout: page 
title: API Documentation
permalink: /api-documentation/
---

Guacamole provides several APIs for extending and embedding Guacamole in existing infrastructures and applications. The majority of the Guacamole codebase actually forms the Guacamole core; the web application named "Guacamole" merely leverages this core, wrapping it in a nice user interface and simple authentication scheme.

You can easily add additional protocol support, support for other authentication methods, or create other HTML5 remote desktop applications using the Guacamole core APIs and associated stack.

C (libguac)
----------------

The C API for extending and developing with Guacamole is libguac. All native components produced by the Guacamole project link with this library, and this library provides the common basis for extending the native functionality of those native components (by implementing client plugins).

libguac is used mainly for developing client plugins like libguac-client-vnc or libguac-client-rdp, or for developing a proxy supporting the Guacamole protocol like guacd. This chapter is intended to give an overview of how libguac is used, and how to use it for general communication with the Guacamole protocol.

[View libguac documentation](/doc/libguac)

Java (guacamole-common)
----------------------------------------

The Java API provided by the Guacamole project is called guacamole-common. It provides a basic means of tunneling data between the JavaScript client provided by guacamole-common-js and the native proxy daemon, guacd. There are other classes provided as well which make dealing with the Guacamole protocol and reading from guacamole.properties easier, but in general, the purpose of this library is to facilitate the creation of custom tunnels between the JavaScript client and guacd.

[View guacamole-common documentation](/doc/guacamole-common)

JavaScript (guacamole-common-js)
---------------------------------------------------

The Guacamole project provides a JavaScript API for interfacing with other components that conform to the design of Guacamole, such as projects using libguac or guacamole-common. This API is called guacamole-common-js.

guacamole-common-js provides a JavaScript implementation of a Guacamole client, as well as tunneling mechanisms for getting protocol data out of JavaScript and into guacd or the server side of a web application.

For convenience, it also provides mouse and keyboard abstraction objects that translate JavaScript mouse, touch, and keyboard events into consistent data that Guacamole can more easily digest. The extendable on-screen keyboard that was developed for the Guacamole web application is also included.

[View guacamole-common-js documentation](/doc/guacamole-common-js)

Extensions (guacamole-ext)
-----------------------------------------

While not strictly part of the Java API provided by the Guacamole project, guacamole-ext is a subset of the API used by the Guacamole web application, exposed within a separate project such that extensions, specifically authentication providers, can be written to tweak Guacamole to fit well in existing deployments.

[View guacamole-ext documentation](/doc/guacamole-ext)
