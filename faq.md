---
layout: page 
title: Frequently Asked Questions
permalink: /faq/
---

* Table of Contents
{:toc}

Bugs / troubleshooting {#problems}
----------------------------------

### Something fundamental to Guacamole isn't working for me. Where do I report this? {#probably-not-a-bug}

Please remember that Guacamole is used by many others without issue, and *the
more fundamental a problem is, the less likely it's a bug*. Before assuming
that you have found a bug, perform basic troubleshooting steps to confirm that
Guacamole itself is the *only* factor affecting whether things work correctly:

* Check Guacamole's logs for errors or warnings related to your configuration.
  These logs are within the logs of your servlet container, such as Apache
  Tomcat. Common locations are `/var/log/tomcat/catalina.out` or within the
  systemd journal (accessed via `journalctl`).
* Check guacd's logs for errors or warnings and and verify that guacd is
  actually running. Messages from guacd are logged to syslog, commonly located
  at `/var/log/syslog`, `/var/log/messages`, or within the systemd journal
  (accessed via `journalctl`).
* Verify that your remote desktop server is actually accessible from the
  Guacamole server using a different remote desktop client.
* Verify that the configuration parameters given for the remote desktop
  connection (including any credentials) are correct.
* Walk through [the installation steps in our official
  documentation](/doc/gug/installing-guacamole.html) and verify that what you
  have done matches what has been documented.

### I have an old or modified version of Guacamole and [X] is not working. Where should I report this? {#test-against-latest-version}

We cannot look into issues which have not actually been reproduced in the
latest version of our code. If the problem you're experiencing has only
been reproduced in an older or modified version of Guacamole, the chance is
high that the problem has either already been addressed (even if you cannot
find a bug report which specifically covers the issue) or that the problem is
due to the difference between your code and upstream (even if you are
absolutely positive this is impossible).

Before reporting an issue upstream, please confirm that the issue exists within
the latest version of the upstream code.

### I have set up the latest version successfully, however if i try [X], instead of [Y] happening as documented, [Z] happens. Where should I report this? {#bug}

We use JIRA to track all known issues and feature requests. If you have found a
bug, please open a new issue in the ASF's JIRA against the "GUACAMOLE" project:

<https://issues.apache.org/jira/browse/GUACAMOLE/>

### I have found an issue which may have security implications. Where should I report this? {#security}

If you have found an issue which may have security implications, **please
follow [responsible
disclosure](https://en.wikipedia.org/wiki/Responsible_disclosure) practices**:

* Report the issue to us privately, either to the private security mailing list
  of the [ASF Security Team](https://www.apache.org/security/) or the
  <security@guacamole.apache.org> mailing list.
* Do not disclose or discuss the issue in a public forum until the Apache
  Guacamole project has addressed the issue and made an [announcement of the
  vulnerability](/security/), or until it has been determined not to be a
  vulnerability at all.

Both the mailing lists and JIRA are public forums and should not be used for
issues with potential security implications. If in doubt, please err on the
side of caution and report the issue privately.

### I'm trying to connect to my remote desktop by it isn't working. Why? {#cannot-connect}

If you can access Guacamole but cannot connect to your remote desktop, the
relevant log messages will be from guacd - the component of the Guacamole stack
which actually handles the low-level connections to remote desktops. Check
guacd's logs for errors or warnings and verify that guacd is actually running.

Messages from guacd are logged to syslog, which is commonly located at
`/var/log/syslog`, `/var/log/messages`, or within the systemd journal (accessed
via `journalctl`). You should also verify that your remote desktop server is
actually accessible from the Guacamole server (using a different remote desktop
client), and that the configuration parameters given for the remote desktop
connection are correct (even if you are positive that you typed them
correctly).

### I am using an application within the remote desktop under Guacamole, but the application isn't working correctly. Can you fix Guacamole so it doesn't break my application? {#remote-application-broken}

No, Guacamole cannot affect your application in this way. The fact that you are
using Guacamole to access the remote desktop has no bearing on whether
applications running under that remote desktop function correctly. If an
application within the remote desktop is malfunctioning, the problem lies
within that application.

### When I connect via RDP, the screen size is set correctly, but it does not update if I resize the browser window. Why? {#resize-rdp}

RDP inherently only supports changing screen size when initially connecting. In
most cases, the screen size of the remote desktop cannot be altered except
when the connection is established, and changing the screen size requires
reconnecting.

### When I connect via VNC, the screen size is not set correctly. It remains the same regardless of the browser window's size. Why? {#resize-vnc}

VNC only supports changing the screen size from within the remote desktop, as
the screen size is dictated by the VNC server. The client side of a VNC
connection cannot dictate the size of the session.

If your VNC server supports changing the screen size of an an active session,
you should be able to do so using standard configuration tools within the
remote desktop, such as the display settings of your desktop environment or
the "xrandr" utility.

Clipboard {#clipboard}
----------------------

### Why don't you just use the clipboard directly instead of the box in the menu? {#local-clipboard}

Guacamole actually already attempts to do this leveraging the [Clipboard
API](https://www.w3.org/TR/clipboard-apis/) defined by the W3C, with support
for the asynchronous version of this API added via
[GUACAMOLE-559](https://issues.apache.org/jira/browse/GUACAMOLE-559). Browsers
vary in their level of support for this API, and some only provide access to
the clipboard under very strict circumstances.

The following browsers are known to support clipboard access:

 * Google Chrome version 66 and later (via the [Asynchronous Clipboard API](https://www.w3.org/TR/clipboard-apis/#async-clipboard-api))
 * Older versions of Google Chrome using the third-party [Clipboard Permission Manager extension](https://chrome.google.com/webstore/detail/clipboard-permission-mana/ipbhneeanpgkaleihlknhjiaamobkceh)
 * IE10 and IE11 (via the older, synchronous version of the API)

This can be expected to change as the asynchronous version of the clipboard API
gains wider adoption.

### I see the browser has "copy" and "paste" events. Why don't you handle these events so clipboard works? {#copy-paste-events}

As much as this might seem like a good idea at first, it is extremely
problematic. In practice, doing so does not work, and actually causes even
more confusion:

 * The "copy" and "paste" events can only be relied upon in response to the
   keyboard shortcuts which cause copy/paste actions on the local machine. Even
   assuming these keyboard shortcuts can be reliably recognized (regardless of
   platform-specific differences in what keys are used to copy/paste), allowed
   to turn into clipboard events, and finally sent through to the remote
   desktop, this is still tied to the keyboard. **Attempts to copy/paste using
   the mouse will fail.**

 * **Different platforms use different keyboard shortcuts for copy/paste**, as
   do different applications within those platforms. The keyboard shortcut
   required to use the clipboard within the remote desktop cannot be guaranteed
   to match the shortcut which would result in clipboard events locally, nor
   can the necessary shortcut be reliably predicted and translated.

 * **The copy operation does not occur instantaneously**, but the browser
   "copy" event requires that clipboard data be set only while the event is
   being handled (within the main thread). Even assuming that the other
   problems above are not an issue, there is no stable, non-deprecated means of
   blocking the main thread such that the clipboard can still be set once the
   data does become available.

While the "copy" and "paste" events can be useful for traditional web
applications, the above issues make them useless for a web application
implementing remote desktop like Guacamole. Instead, we use the [Clipboard
API](https://www.w3.org/TR/clipboard-apis/) defined by the W3C, and rely on
the browser to provide its own method of granting access to the clipboard.

Keyboard / input {#user-input}
------------------------------

### I press [keyboard shortcut] but it's handled by my browser or operating system instead of the remote desktop. Can you fix this? {#keyboard-shortcuts}

Guacamole actually already attempts to handle all keyboard events. However, if
your browser or operating system reserve some keyboard shortcuts for their own
use. Keyboard events propagate from the operating system level, to the browser
level, and finally into JavaScript where Guacamole resides. Guacamole can only
take control of a keyboard event if each level above Guacamole allows it to do
so.

Most browsers now provide a means of bookmarking a web application as a
shortcut on the desktop or home screen such that it behaves more like a native
application, lacks the normal URL bar, etc. In these cases, the browser will
often allow the application to take control of additional keyboard shortcuts
which would normally be reserved for the browser. If you are running into this
problem, or simply want to use Guacamole as if it were a native application,
this is definitely worth a try.

### Does Guacamole support my keyboard layout?

Guacamole is actually independent of keyboard layout, and will send the true
local identity of the key pressed. The behavior of each key within the remote
desktop should identically match the local behavior of that key.

This holds true for most of Guacamole's supported protocols, but things get
more complex for RDP. Unlike Guacamole, RDP uses scancodes to represent each
key, which are a numeric representation of that key's location, not its
identity. To translate the identity of the key into the scancode required by
your RDP server, Guacamole must know the keyboard layout of your RDP server,
and must have explicit support for that keyboard layout.

**This does not mean that your RDP server must have the same keyboard layout as
the client machine.** It only means that Guacamole must have a keyboard layout
definition for the layout used by the RDP server. If a user attempts to use a
keyboard with a different layout, Guacamole will translate pressed keys as
necessary to match the layout of the RDP server. If the user attempts to press
keys which are not present in the keyboard layout of the RDP server, Guacamole
will send those keys in the form of Unicode events.

If you are using an RDP server which does not support Unicode events (such as
XRDP), locally-pressed keys must have matching keys within the RDP server's
keyboard layout, or they cannot be typed.


File transfer and device redirection {#device-redirection}
----------------------------------------------------------

### I need to share files on my computer with the remote desktop. I see Guacamole has drive redirection support, but only for files accessible to the Guacamole server. How can I share local files? {#local-files}

Unfortunately, this is not possible. JavaScript cannot access local files
directly. You *can* still share local files, but they must be manually uploaded
using Guacamole's file transfer support.

### I want to print to my local printer. I see Guacamole has printing support, but this produces a PDF download. How do I print directly to my local printers? {#local-printers}

This is not possible, as JavaScript cannot access local printers. While it is
technically possible to cause the PDF to automatically open a print dialog, and
on some browsers it is also possible to automatically open the PDF, this does
not currently work reliably across all platforms, and whether it will work
cannot be detected/predicted. The only reliable mechanism is the one already
implemented by Guacamole: file transfer of a standard format like PDF.

Supported protocols {#protocols}
--------------------------------

### Can you add support for X11 forwarding to SSH? {#x11-forwarding}

No. Because of the complexity involved in implementing an X11 server, this
wouldn't actually work well in practice, however [a graphics driver
for the X.Org X11 server is currently being
written](https://issues.apache.org/jira/browse/GUACAMOLE-168). This driver
functions as a display and set of input devices which implement the Guacamole
protocol, and should be quite fast.

### NX is faster than VNC. Can you add support for NX? {#support-nx}

No. Adding support for NX to Guacamole is not actually as straightforward as it
sounds. Unlike remote desktop protocols like VNC and RDP, the protocol referred
to as "NX" or "NXv3" is actually a method of compressing yet another protocol:
X11. As discussed above, implementing support for X11 does not actually make
sense for Guacamole, but there is an X.Org driver which achieves the same goal.

"NXv4", on the other hand, is proprietary and not publicly documented. No open
source implementations of this protocol exist. Unless it becomes publicly
documented, or an open source implementation is created, it is not feasible for
support for NXv4 to be added to Guacamole.

### X2Go is faster than VNC. Can you add support for X2Go? {#support-x2go}

No. X2Go is actually an implementation of NX, which is actually a compression
method for X11, which is too complex. This is not necessary, though - as far as
performance is concerned, there is an X.Org driver for Guacamole currently
under development which achieves the same goal (see above).

Development / integration {#development}
----------------------------------------

### I want to put Guacamole in an `<iframe>` but keyboard doesn't work correctly. {#iframes}

It is generally not recommended to rely on `<iframe>` to integrate Guacamole
for precisely this reason. Browser keyboard focus is problematic if an
`<iframe>` is used, as once focus has been lost, clicking within the `<iframe>`
will not necessarily return keyboard focus to Guacamole.

Rather than use an `<iframe>`, you should instead look into leveraging
Guacamole's JavaScript API,
[guacamole-common-js](/doc/gug/guacamole-common-js.html), thus integrating
Guacamole into your page directly. You might even consider building your own
web application from Guacamole's core Java API,
[guacamole-common](/doc/gug/guacamole-common.html), if that would provide a
better experience.

If an `<iframe>` is really the only feasible solution, you can work around
keyboard focus issues by automatically refocusing the `<iframe>` whenever focus
is not explicitly on some other part of the page.  For example, assuming the
variable `iframe` points to the DOM element of the `<iframe>` containing
Guacamole, you could refocus Guacamole by default with something like:

    /**
     * Refocuses the iframe containing Guacamole if the user is not already
     * focusing another non-body element on the page.
     */
    var refocusGuacamole = function refocusGuacamole() {

        // Do not refocus if focus is on an input field
        var focused = document.activeElement;
        if (focused && focused !== document.body)
            return;

        // Ensure iframe is focused
        iframe.focus();

    };

    // Attempt to refocus iframe upon click or keydown
    document.addEventListener('click', refocusGuacamole);
    document.addEventListener('keydown', refocusGuacamole);

### I want to integrate Guacamole into my application, so I've written a script which updates the database / XML / ... {#integrate-auth}

There is no need to do this. While dynamically updating the XML or database
contents may seem invitingly simple, it is rarely the best approach. Guacamole
provides an API for integrating itself with other authentication systems and
sources of data: [guacamole-ext](/doc/gug/guacamole-ext.html). Rather than
attempt to keep an independent, Guacamole-specific source of data updated with
respect to your application, it is better to pull or derive that data directly
within an extension built specifically to integrate Guacamole with your
application.

The manual provides a basic example for [implementing your own Guacamole
extension](/doc/gug/custom-auth.html), and the various extensions included
as part of [guacamole-client](https://github.com/apache/guacamole-client)
are well-commented and can serve as more in-depth demonstrations of what is
possible with this API.

If the ultimate goal is to tightly integrate Guacamole within your application,
and Guacamole's authentication model and interface don't quite match what you
intend, you should also consider [building your own web
application](/doc/gug/writing-you-own-guacamole-app.html). Guacamole's is built
on a set of APIs which are maintained independently from the web application of
the same name specifically so that other applications, like yours, can be built
from the same underlying technology.

### My application already does authentication. How do I disable authentication within Guacamole? {#disable-auth}

**DO NOT DISABLE GUACAMOLE'S AUTHENTICATION!** There are no use cases where
this is a good idea. Even if you are absolutely positive that users cannot
access Guacamole without first being authenticated elsewhere, validating each
user's authenticated state is the *only* safe choice. You don't need to force
users to log in multiple times, but you *do* need to verify that they are
actually logged in.

If you have an application which already handles authentication, the correct
and safe way to integrate Guacamole with that application is to write a
Guacamole extension which validates each user. If the connections available to
each user will vary depending on that existing system, your extension can
dynamically derive those connections by querying your existing system, as well.

