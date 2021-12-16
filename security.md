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

Is Apache Guacamole affected by CVE-2021-44228? {#not-affected-by-cve-2021-44228}
-----------------------------------------------

No, CVE-2021-44228 does not affect Apache Guacamole. Guacamole uses
[Logback](http://logback.qos.ch/) as its logging backend, not Log4j.

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

