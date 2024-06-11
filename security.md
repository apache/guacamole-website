---
layout: page 
title: Security Reports
permalink: /security/
---

This page lists all security vulnerabilities fixed in released versions of
Apache Guacamole. Each vulnerability is listed with a description of the
problem, its associated [CVE
number](https://cve.mitre.org/about/faqs.html#what_is_cve_id), and the
Guacamole release in which the vulnerability was fixed.

Reporting new vulnerabilities
-----------------------------

If you believe you have discovered a security problem in Apache Guacamole,
please follow [responsible
disclosure](https://en.wikipedia.org/wiki/Responsible_disclosure) practices and
report discovered security issues privately, either to the private security
mailing list of the [ASF Security Team](https://www.apache.org/security/) or
the <security@guacamole.apache.org> mailing list, before disclosing or
discussing the issue in a public forum.

Vulnerabilities in dependencies
-------------------------------

### Is Apache Guacamole affected by CVE-2023-5129? {#not-affected-by-cve-2023-5129}

No. CVE-2023-5129 (aka CVE-2023-4863) deals specifically with decoding
WebP images, not encoding.

You would also receive updates to libwebp from your distribution as the
library itself is not bundled within Guacamole. If using our Docker
images, the images are automatically rebuilt nightly to bring in updates
from the maintainer of the base image (Alpine Linux), and a pull of the
latest would give you an updated image.

### Is Apache Guacamole affected by CVE-2021-44228? {#not-affected-by-cve-2021-44228}

No, CVE-2021-44228 does not affect Apache Guacamole. Guacamole uses
[Logback](http://logback.qos.ch/) as its logging backend, not Log4j.

### Is Apache Guacamole affected by AngularJS vulnerabilities? {#not-affected-angularjs}

No. Apache Guacamole does currently rely on AngularJS, which has gone
end-of-life and is no longer being actively developed or supported. While
AngularJS has several vulnerabilities, we have verified that Guacamole
is not impacted by any current known vulnerabilities, either because
the affected component is not in use in Guacamole, or because there is
no known exploitation path.

{% assign releases = site.releases  | where: 'released', 'true' | sort: 'date' %}
{% for release in releases reversed %}

    {% assign reports = site.security | where: 'fixed', release.title | sort: 'title' %}
    {% capture title %} Fixed in Apache Guacamole {{ release.title }} {% endcapture %}
    {% include cve-list.html title=title reports=reports %}

{% endfor %}

{% assign releases = site.legacy-releases | sort: 'date' %}
{% for release in releases reversed %}

    {% assign reports = site.security | where: 'fixed', release.title | sort: 'title' %}
    {% capture title %} Fixed in Guacamole {{ release.title }} (pre-Apache release) {% endcapture %}
    {% include cve-list.html title=title reports=reports %}

{% endfor %}

{% assign reports = site.security | where: 'fixed', '0.6.3' | sort: 'title' %}
{% capture title %} Fixed in Guacamole 0.6.3 (pre-Apache release) {% endcapture %}
{% include cve-list.html title=title reports=reports %}

