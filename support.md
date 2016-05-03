---
layout: page 
title: Help / Support
permalink: /support/

menu-title:  Help / Support
menu-weight: 7
---

If you need (or wish to provide) help with Guacamole, the primary means for
doing so are the project [mailing lists](#mailing-lists). All project members
subscribe to these lists, and members of the community are encouraged to do the
same.

We consider the availability of commercial support to be crucial to the
success of Apache Guacamole, and maintain a list of [third party
companies](#commercial-support) providing commercial support. If you provide
commercial support and would like your company to be listed, please send us an
email, and we will work with you to do so.

The Guacamole project historically used the [SourceForge
forums](https://sourceforge.net/p/guacamole/discussion/), so it is worth
searching through past threads there to see if your question has been asked and
answered, but **please do not uses these forums for new posts**.  New questions
should use the mailing lists. Any further posts to the forums will be asked to
use the mailing instead.

Mailing Lists
-------------

If you would like help with Apache Guacamole, or wish to help others, we highly
recommend sending an email to the one of the project's mailing lists. **You
will need to subscribe prior to sending email to any list.** All mailing lists
are actively filtered for spam, and any email not originating from a subscriber
will bounce.

### General Discussion / Questions ([user@guacamole.incubator.apache.org](mailto:user@guacamole.incubator.apache.org))

The general/users list is indended for general questions and discussions which
do not necessarily pertain to development. This list replaces the old
[SourceForge forums](https://sourceforge.net/p/guacamole/discussion/) used by
Guacamole prior to its acceptance into the Apache Incubator.

* [Subscribe](mailto:user-subscribe@guacamole.incubator.apache.org)
* [Unsubscribe](mailto:user-unsubscribe@guacamole.incubator.apache.org)
* [Archives](http://mail-archives.apache.org/mod_mbox/incubator-guacamole-user/)

### Development ([dev@guacamole.incubator.apache.org](mailto:dev@guacamole.incubator.apache.org))

The development list is for development-related discussion involving people who
are contributors to the Apache Guacamole project (or who wish to become
contributors).

* [Subscribe](mailto:dev-subscribe@guacamole.incubator.apache.org)
* [Unsubscribe](mailto:dev-unsubscribe@guacamole.incubator.apache.org)
* [Archives](http://mail-archives.apache.org/mod_mbox/incubator-guacamole-dev/)

[The Guacamole Manual](/doc/gug/)
---------------------------------

The central body of documentation is the [Guacamole manual](/doc/gug/). It is kept up-to-date with each release, and provides a massive amount of information in one place. The manual contains installation and configuration instructions, as well as instructions for using the application itself. There is also a large section devoted entirely to development tutorials and descriptions of the architecture and APIs of the Guacamole core.

The Guacamole team monitors the IRC channels and SourceForge forums daily and responds whenever time permits.

Commercial Support
------------------------------

As some of the main target audiences for Apache Guacamole are enterprises and
companies that need to provide access to many computers (hence its design as a
gateway), we consider the availability of commercial support crucial to
Guacamole's success. If you provide commercial support and would like your
company to be listed, please send us an email, and we will work with you to do
so.

Companies providing support for Apache Guacamole are not endorsed by the Apache
Software Foundation, though some such companies do employ committers of the
Apache Guacamole project.

<ul class="company-list">
    {% for company in site.companies %}
        <li class="company">
            {% if company.logo %}
                <div class="company-logo"><a href="{{ company.location }}"><img src="{{ company.logo }}"/></a></div>
            {% endif %}
            <div class="company-description">
                <h3><a href="{{ company.location }}">{{ company.title }}</a></h3>
                {{ company.content }}
            </div>
        </li>
    {% endfor %}
</ul>

