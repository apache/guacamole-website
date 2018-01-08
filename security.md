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
the <private@guacamole.apache.org> mailing list, before disclosing or
discussing the issue in a public forum.

{% assign releases = site.security | group_by: 'fixed' %}
{% for release in releases reversed %}

Fixed in Apache Guacamole {{ release.name }}
--------------------------------------------

<ul>
    {% assign reports = release.items | sort: 'title' %}
    {% for report in reports %}
    <li>
        <h3 id="{{ report.cve }}">
            {{ report.title }}
            (<a href="https://cve.mitre.org/cgi-bin/cvename.cgi?name={{ report.cve | url_encode }}">{{ report.cve }}</a>)
        </h3>
        {{ report.content }}
    </li>
    {% endfor %}
</ul>
{% endfor %}

