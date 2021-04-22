---
layout: page 
title: Announcing the release
permalink: /release-procedures-part4/
---

* Table of contents
{:toc}

Update website announcing the release {#update-website}
-------------------------------------------------------

Once the full 24 hours has elapsed since [the final release artifacts were
uploaded](/release-procedures-part3/#final-upload), the website must be updated
to point to the new release. There are three specific things which must be
updated:

1. The top-level symbolic links within `/doc` must be updated to point to the
   documentation of the latest release.

2. The `released: false` field at the top of the release notes needs to be
   updated to `released: true` to allow the release to be listed with the rest
   in the [release archives](/releases/). The `date` field should also be
   updated to note the actual date and time of release.

3. The `artifact-url`, `checksum-url`, and `download-path` must be updated
   to use the release directory (rather than the RC directory) and to *not*
   use `dist.apache.org`.

Example: [the pull request for guacamole-website announcing 0.9.11-incubating](https://github.com/apache/guacamole-website/pull/31)

Update JIRA version information {#update-jira}
----------------------------------------------

JIRA must be updated as well, as each version is listed for the sake of tagging
issues. At this point, there should already be a version created for the recent
release, but it will not be marked as released. Mark the version as "released"
within JIRA, making sure a version number for the next release has been created
as a placeholder:

<https://issues.apache.org/jira/plugins/servlet/project-config/GUACAMOLE/versions>

Email announcement {#email-announce}
------------------------------------

Finally, send an email with the subject `[ANNOUNCE] Apache Guacamole [VERSION]
released` to <announce@apache.org>, <dev@guacamole.apache.org>, and
<user@guacamole.apache.org>. **This email MUST be sent from an apache.org
email address**, and should contain an announcement like the following:

```
The Apache Guacamole community is proud to announce the release of Apache
Guacamole [VERSION].

Apache Guacamole is a clientless remote desktop gateway which supports standard
protocols like VNC, RDP, and SSH. We call it "clientless" because no plugins or
client software are required; once Guacamole is installed on a server, all you
need to access your desktops is a web browser.

[VERSION] features [RELEASE HIGHLIGHTS].

A full list of the changes in this release, along with links to downloads
and updated documentation, can be found in the release notes:

http://guacamole.apache.org/releases/[VERSION]/

For more information on Apache Guacamole, please see:

http://guacamole.apache.org/

Thanks!

The Apache Guacamole Community
```

Where `[VERSION]` is the version that was just released and `[RELEASE
HIGHLIGHTS]` is a brief description of the key features, improvements, and bug
fixes of the release.

Example: [the 0.9.10-incubating announcement email](http://mail-archives.apache.org/mod_mbox/www-announce/201612.mbox/%3CCALKeL-PxDiixdCkpLcVE9XN07aRUVx1aPR%3D5ysaAJjKdU1ZnNg%40mail.gmail.com%3E)

