Introduction
============

This book is the official Apache Guacamole manual, written by the upstream
developers of the Guacamole project. It is also the official general
documentation, with an online version available at
<http://guacamole.apache.org/>. It is a work in progress which will be
continuously updated as Guacamole changes with each release.

We decided to maintain the documentation for Guacamole as a book, as there is
an awful lot that can be done with the Guacamole web application, and even more
that can be done with the API. This book is intended to explore the
possibilities of Guacamole as an application, and to provide documentation
necessary to install, maintain, and use Guacamole.

For the sake of users and administrators, we have provided a high-level
overview of Guacamole's architecture and technical design, as well as basic
usage instructions and installation instructions for common platforms.

For the sake of developers, we have provided a protocol reference and tutorials
for common tasks (implementing protocol support, integrating Guacamole into
your own application, etc.) to give a good starting point beyond simply looking
at the Guacamole codebase.

This particular edition of the Guacamole Manual covers Guacamole version
{{ version }}. New releases which create new features or break compatibility
will result in new editions of the user's guide, as will any necessary
corrections.  As the official documentation for the project, this book will
always be freely available in its entirety online.

(what-is-guac)=

What is Guacamole?
------------------

Guacamole is an HTML5 web application that provides access to desktop
environments using remote desktop protocols (such as VNC or RDP).
Guacamole is also the project that produces this web application, and
provides an API that drives it. This API can be used to power other
similar applications or services.

"Guacamole" is most commonly used to refer to the web application
produced by the Guacamole project using their API. This web application
is part of a stack that provides a protocol-agnostic remote desktop
gateway. Written in JavaScript and using only HTML5 and other standards,
the client part of Guacamole requires nothing more than a modern web
browser or web-enabled device when accessing any of the desktops served.

Historically, Guacamole was an HTML5 VNC client, and before that, a
JavaScript Telnet client called RealMint ("RealMint" is an anagram for
"terminal"), but this is no longer the case. Guacamole's architecture
has grown to encompass remote desktop in general, and can be used as a
gateway for any number of computers. Originally a proof-of-concept,
Guacamole is now performant enough for daily use, and all Guacamole
development is done over Guacamole.

As an API, Guacamole provides a common and efficient means of streaming
text data over a JavaScript-based tunnel using either HTTP or WebSocket,
and a client implementation which supports the Guacamole protocol and
renders the remote display when combined with a Guacamole protocol
stream from the tunnel.

It provides cross-browser mouse and keyboard events, an XML-driven
on-screen keyboard, and synchronized nestable layers with
hardware-accelerated compositing. Projects that wish to provide remote
desktop support over HTML5 can leverage the years of research and
development that went into Guacamole by incorporating the API into their
application or service.

(access-from-anywhere)=

Why use Guacamole?
------------------

The principle reason to use Guacamole is constant, world-wide,
unfettered access to your computers.

Guacamole allows access one or more desktops from anywhere remotely,
without having to install a client, particularly when installing a
client is not possible. By setting up a Guacamole server, you can
provide access to any other computer on the network from virtually any
other computer on the internet, anywhere in the world. Even mobile
phones or tablets can be used, without having to install anything.

As a true web application whose communication is over HTTP or HTTPS
only, Guacamole allows you to access your machines from anywhere without
violating the policy of your workplace, and without requiring the
installation of special clients. The presence of a proxy or corporate
firewall does not prevent Guacamole use.

(access-from-anything)=

Access your computers from any device
-------------------------------------

As Guacamole requires only a reasonably-fast, standards-compliant
browser, Guacamole will run on many devices, including mobile phones and
tablets.

Guacamole is specifically designed to not care whether you have a mouse,
keyboard, touchscreen, or any combination of those.

One of the major design philosophies behind Guacamole is that it should
never assume you have a particular device (ie: a mobile phone) just
because your browser has or is missing a specific feature (ie: touch
events or a smallish screen). Guacamole's codebase provides support for
both mouse and touch events simultaneously, without choosing one over
the other, while the interface is intended to be usable regardless of
screen size.

Barring bugs, you should be able to use Guacamole on just about any
modern device with a web browser.

(non-physical-computer)=

Keep a computer in the "cloud"
------------------------------

Ignoring the buzzword, it's often useful to have a computer that has no
dedicated physical hardware, where its processing and storage power are
handled transparently by redundant systems in some remote datacenter.

Computers hosted on virtualized hardware are more resilient to failures,
and with so many companies now offering on-demand computing resources,
Guacamole is a perfect way to access several machines that are only
accessible over the internet.

In fact, all Guacamole development is done on computers like this. This
is partly because we like the mobility, and partly because we want to
ensure Guacamole is always performant enough for daily use.

(group-access)=

Provide easy access to a group
------------------------------

Guacamole allows you to centralize access to a large group of machines,
and specify on a per-user basis which machines are accessible. Rather
than remember a list of machines and credentials, users need only log
into a central server and click on one of the connections listed.

If you have multiple computers which you would like to access remotely,
or you are part of a group where each person has a set of machines that
they need remote access to, Guacamole is a good way to provide that
access while also ensuring that access is available from anywhere.

(adding-remote-access)=

Adding HTML5 remote access to your existing infrastructure
----------------------------------------------------------

As Guacamole is an API, not just a web application, the core components
and libraries provided by the Guacamole project can be used to add HTML5
remote access features to an existing application. You need not use the
main Guacamole web application; you can write (or integrate with) your
own rather easily.

If you host an on-demand computing service, adding HTML5-based remote
access allows users of your service more broad access; users need
nothing more than a web browser to see their computers' screens.

