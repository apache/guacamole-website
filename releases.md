---
layout: page 
title: Release Archive
permalink: /releases/

menu-title:  Downloads
menu-weight: 0
menu-class:  download
---

All recent Guacamole releases are listed here, along with several historical releases. Each release below is listed by the version of the overall software bundle and the date on which it was released. Clicking on the version number will take you to the release notes and downloads for that release, including a pre-built `guacamole.war` file and all associated source code.

Please be sure to read the [installation instructions](/doc/gug/installing-guacamole.html) in the [manual](/doc/gug/) thoroughly. If you do not wish to build things from source, you can also [install Guacamole using Docker](/doc/gug/guacamole-docker.html).

If you are looking for the absolute latest unreleased code (or extremely old code not archived here), please check our git repositories on [GitHub](https://github.com/glyptodon/).

Which version should I download?
------------------------------------------------

Unless you already know that you need a *very* specific version (your custom or third-party extensions use an older version of the Guacamole API, for example), **you should always download the most recent release**. Guacamole development is very active, and recent releases will contain bug fixes and performance improvements that will be absent in older releases.

<table class="releases">
    <tr>
        <th>Version</th>
        <th>Summary</th>
        <th>Release Date</th>
    </tr>
    {% for release in site.releases %}
        {% if release.title %}
            <tr>
                <td><a href="{{ release.url | prepend: site.baseurl }}">{{ release.title }}</a></td>
                <td>{{ release.summary }}</td>
                <td>{{ release.date | date: "%Y-%m-%d" }}</td>
            </tr>
        {% endif %}
    {% endfor %}
</table>

