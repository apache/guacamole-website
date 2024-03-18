---
layout: page 
title: Help / Support
permalink: /support/
---

If you need (or wish to provide) help with Guacamole, the primary means for
doing so are the project [mailing lists](#mailing-lists). All project members
subscribe to these lists, and members of the community are encouraged to do the
same.

We also consider the availability of commercial support to be crucial to the
success of Apache Guacamole, and thus maintain [a list of third party
companies providing commercial support](#commercial-support). If you represent
a company that provides commercial support for Apache Guacamole, you may also
[request to be listed here](#requesting-to-be-listed).

Mailing Lists
-------------

Like all other projects under Apache or the Apache Incubator, mailing lists
form Guacamole's primary support channel and the means by which development
is coordinated.

If you would like help with Apache Guacamole, or wish to help others, we highly
recommend sending an email to the one of the project's mailing lists. **You
will need to subscribe prior to sending email to any list.** All mailing lists
are actively filtered for spam, and any email not originating from a subscriber
will bounce.

<div class="note">
    <p>Before posting to any Apache Guacamole mailing list, please remember to
be respectful and considerate of the community that subscribes to that
list:</p>
    <ul>
        <li>Abide by <a href="https://www.apache.org/foundation/policies/conduct.html">the ASF's Code of Conduct</a>.</li>
        <li><strong>DO NOT</strong> send unsolicited messages advertising a product or service.</li>
        <li><strong>DO NOT</strong> use the mailing lists to promote proprietary enhancements.</li>
    </ul>
    <p>Thank you!</p>
</div>

{% assign lists = site.mailing-lists | where: 'category', 'primary' %}
{% include mailing-list-list.html mailing-lists=lists %}

[The Guacamole Manual](/doc/gug/)
---------------------------------

The central body of documentation is the [Guacamole manual](/doc/gug/). It is kept up-to-date with each release, and provides a massive amount of information in one place. The manual contains installation and configuration instructions, as well as instructions for using the application itself. There is also a large section devoted entirely to development tutorials and descriptions of the architecture and APIs of the Guacamole core.

Commercial Support
------------------------------

As some of the main target audiences for Apache Guacamole are enterprises and
companies that need to provide access to many computers (hence its design as a
gateway), we consider the availability of commercial support crucial to
Guacamole's success. The companies listed below have requested to be listed as
commercial support providers. If you represent a company that provides
commercial support for Apache Guacamole, you may also [request to be listed
here](#requesting-to-be-listed).

<div class="note">
    <p>Companies providing support for Apache Guacamole are <strong>not
endorsed nor vetted</strong> by the Apache Software Foundation, though some
such companies do employ committers of the Apache Guacamole project. The links,
logos, names, and descriptions below were provided by their respective
companies.</p>
</div>

<ul class="company-list">
    {% for company in site.companies %}
        <li class="company">
            {% if company.logo %}
                <div class="company-logo"><a href="{{ company.location }}" rel="nofollow"><img src="{{ company.logo }}" alt="Logo for {{ company.title }}"/></a></div>
            {% endif %}
            <div class="company-description">
                <h3><a href="{{ company.location }}" rel="nofollow">{{ company.title }}</a></h3>
                {{ company.content }}
            </div>
        </li>
    {% endfor %}
</ul>

### Requesting to be listed

If you provide commercial support and would like your company to be listed,
please [open a pull request against the Apache Guacamole website](https://github.com/apache/guacamole-website)
and we will work with you to add your company to the list. The criteria to be
listed are:

1. Your company appears to exist.
2. Your company's website publicly lists that you provide support for Apache Guacamole in some capacity.
3. You provide a short blurb describing your company (no more than 50 words). The blurb must
   be written in a neutral and factual manner (avoid subjective assertions).
4. You provide a PNG or JPEG logo no more than 144x144 pixels in size.

