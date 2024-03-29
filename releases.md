---
layout: page 
title: Release Archives
permalink: /releases/
---

All recent Guacamole releases are listed here, along with several historical releases. Each release below is listed by the version of the overall software bundle and the date on which it was released. Clicking on the version number will take you to the release notes and downloads for that release, including a pre-built `guacamole.war` file and all associated source code.

Please be sure to read the [installation instructions](/doc/gug/installing-guacamole.html) in the [manual](/doc/gug/) thoroughly. If you do not wish to build things from source, you can also [install Guacamole using Docker](/doc/gug/guacamole-docker.html).

If you are looking for the absolute latest unreleased code (or extremely old code not archived here), please check our git repositories on GitHub.

Which version should I download?
------------------------------------------------

Unless you already know that you need a *very* specific version (your custom or third-party extensions use an older version of the Guacamole API, for example), **you should always download the most recent release**. Guacamole development is very active, and recent releases will contain bug fixes and performance improvements that will be absent in older releases.

<ul class="releases ">

    <!-- Current Release -->
    {% assign releases = site.releases  | where: 'released', 'true' | sort: 'date' | reverse | slice: 0 %}
    {% include release-list.html class="current" title="Current Release" releases=releases %}

    <!-- Archived Releases -->
    {% assign releases = site.releases | where: 'released', 'true' | sort: 'date' | reverse | slice: 1, site.releases.size %}
    {% include release-list.html class="archived" title="Archived Releases" releases=releases %}

    <!-- Incubator Releases -->
    {% assign releases = site.incubator-releases | where: 'released', 'true' | sort: 'date' | reverse %}
    {% include release-list.html class="incubator" title="Incubator Releases" releases=releases %}

    <!-- Pre-Apache Releases -->
    {% assign releases = site.legacy-releases | sort: 'date' | reverse %}
    {% capture pre_apache_description %}
        <div class="note">
            <p><strong>All releases below are from prior to Guacamole's
            acceptance into the Incubator.</strong> They are not Apache
            Software Foundation releases, and are licensed under the
            <a href="https://opensource.org/licenses/MIT">MIT license</a>.</p>
        </div>
    {% endcapture %}
    {% include release-list.html class="pre-apache" title="Pre-Apache Releases"
        description=pre_apache_description releases=releases %}

</ul>

