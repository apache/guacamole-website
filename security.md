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

No. We routinely check for known vulnerabilities in AngularJS and manually
verify that Guacamole is not impacted by each.

{% capture angularjs_details %}
<table>
    <thead>
        <tr>
            <th>CVE ID</th>
            <th>Analysis</th>
        </tr>
    </thead>
    <tbody>
        {% assign analyses = site.angularjs-cves | sort: 'cve' %}
        {% for analysis in analyses %}
            <tr>
                <td>
                    <a id="{{ analysis.cve | escape }}" target="_blank"
                       href="https://www.cve.org/CVERecord?id={{ analysis.cve | url_encode }}"
                       title="{{ analysis.title | escape }}">{{ analysis.cve }}</a>
                </td>
                <td>{{ analysis.content }}</td>
            </tr>
        {% endfor %}
    </tbody>
</table>
{% endcapture %}
{% include expandable-figure.html
    title="Table of vulnerabilities and corresponding analyses"
    content=angularjs_details %}

**If you believe a new vulnerability in AngularJS may require specific
remediation within Guacamole, please reach out to us by sending an email to
<security@guacamole.apache.org> and we will investigate promptly.** If a
potential vulnerability in AngularJS _does_ need to be addressed, we will work
with you to issue a release of Guacamole that addresses it.

Releases of Guacamole 1.x will continue to use AngularJS for compatibility,
while Guacamole 2.0.0 onward is planned to use Angular (the TypeScript-based
framework that supersedes AngularJS).

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

