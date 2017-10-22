---
layout: page 
title: Podling Maturity Evaluation
permalink: /maturity-evaluation/
---

This is an assessment of the Guacamole podling’s maturity, meant to help inform
the decision (of the mentors, community, Incubator PMC and ASF Board of
Directors) to graduate it as a top-level Apache project. It is based on [the
ASF project maturity model](http://community.apache.org/apache-way/apache-project-maturity-model.html).

Code
----

CD10
: The project produces Open Source software, for distribution to the public at
  no charge.

  **OK:** We sure do.

CD20
: The project's code is easily discoverable and publicly accessible.

  **OK:** The GitHub mirrors of the project's git repositories are linked
  within the website navigation menu, and the source for each release is linked
  within the release notes.

CD30
: The code can be built in a reproducible way using widely available standard
  tools.

  **OK:** The two bodies of code making up Guacamole, "guacamole-client" and
  "guacamole-server", are built with Apache Maven and GNU Autotools
  respectively.

CD40
: The full history of the project's code is available via a source code control
  system, in a way that allows any released version to be recreated.

  **OK:** The full history of the project's code can be found within the git
  repositories, and each release has a corresponding tag whose format is
  dictated by [our release procedures](/release-procedures-part3/#final-tag).

CD50
: The provenance of each line of code is established via the source code
  control system, in a reliable way based on strong authentication of the
  committer. When third-party contributions are committed, commit messages
  provide reliable information about the code provenance.

  **OK:** Commits are accepted only through pull requests [after having been
  reviewed by other committers](/pull-requests/), and git inherently records
  the name and email address of the author for each commit.

Licenses and Copyright
----------------------

LC10
: The code is released under the Apache License, version 2.0.

  **OK:** All code from the project is under the Apache License, version 2.0.
  See:

   * <https://github.com/apache/incubator-guacamole-client/blob/master/LICENSE>
   * <https://github.com/apache/incubator-guacamole-server/blob/master/LICENSE>

LC20
: Libraries that are mandatory dependencies of the project's code do not create
  more restrictions than the Apache License does.

  **OK:** The mandatory dependencies of "guacamole-server" (Cairo, libjpeg /
  libjpeg-turbo, libpng, and OSSP UUID) and "guacamole-client" (documented
  within the `LICENSE` files of guacamole-client and its subprojects) do not
  impose restrictions beyond that of the Apache license.

  Mandatory dependencies of "guacamole-server" (written in C, built using
  GNU Autotools):

   * Cairo (Mozilla Public License)
   * libjpeg OR libjpeg-turbo (The [IJG license](https://github.com/libjpeg-turbo/libjpeg-turbo/blob/master/README.ijg),
     as well as modified BSD and the zlib license. See: <https://github.com/libjpeg-turbo/libjpeg-turbo/blob/master/LICENSE.md>)
   * libpng ([libpng license](http://www.libpng.org/pub/png/src/libpng-LICENSE.txt))
   * OSSP UUID (MIT license)

  Mandatory dependencies of "guacamole-client" (written in Java and
  JavaScript, built using Maven):

   * Dependencies bundled with the source are documented in [the top-level `LICENSE` file](https://github.com/apache/incubator-guacamole-client/blob/master/LICENSE).
   * Dependencies bundled with the various binaries are documented at the end
     of artifact-specific `LICENSE` files:
      * [`guacamole/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/guacamole/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-header/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-header/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-dist/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-dist/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-cas/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-cas/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-ldap/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-ldap/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-duo/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-duo/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-openid/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-openid/src/licenses/LICENSE)
      * [`extensions/guacamole-auth-noauth/src/licenses/LICENSE`](https://github.com/apache/incubator-guacamole-client/blob/master/extensions/guacamole-auth-noauth/src/licenses/LICENSE)

LC30
: The libraries mentioned in LC20 are available as Open Source software.

  **OK:** Absolutely all dependencies of "guacamole-server" and
  "guacamole-client" are open source.

LC40
: Committers are bound by an Individual Contributor Agreement (the "Apache
  iCLA") that defines which code they are allowed to commit and how they need
  to identify code that is not their own.

  **OK:** All committers have completed the ICLA.

LC50
: The copyright ownership of everything that the project produces is clearly
  defined and documented.

  **OK:** All source files carry prominent header comments documenting the
  license and copyright ownership of that file, with the exception of files
  which inherently cannot contain comments (JSON) and files where includng
  such comments would hurt the performance of the application (AngularJS
  templates). Copyright ownership and license of the source overall is
  always documented with top-level `LICENSE` and `NOTICE` files.

Releases
--------

RE10
: Releases consist of source code, distributed using standard and open archive
  formats that are expected to stay readable in the long term.

  ?

RE20
: Releases are approved by the project's PMC (see CS10), in order to make them
  an act of the Foundation.

  ?

RE30
: Releases are signed and/or distributed along with digests that can be
  reliably used to validate the downloaded archives.

  ?

RE40
: Convenience binaries can be distributed alongside source code but they are
  not Apache Releases -- they are just a convenience provided with no
  guarantee.

  ?

RE50
: The release process is documented and repeatable to the extent that someone
  new to the project is able to independently generate the complete set of
  artifacts required for a release.

  ?

Quality
-------

QU10
: The project is open and honest about the quality of its code. Various levels
  of quality and maturity for various modules are natural and acceptable as
  long as they are clearly communicated.

  ?

QU20
: The project puts a very high priority on producing secure software.

  ?

QU30
: The project provides a well-documented, secure and private channel to report
  security issues, along with a documented way of responding to them.

  ?

QU40
: The project puts a high priority on backwards compatibility and aims to
  document any incompatible changes and provide tools and documentation to help
  users transition to new features.

  ?

QU50
: The project strives to respond to documented bug reports in a timely manner.

  ?

Community
---------

CO10
: The project has a well-known homepage that points to all the information
  required to operate according to this maturity model.

  ?

CO20
: The community welcomes contributions from anyone who acts in good faith and
  in a respectful manner and adds value to the project.

  ?

CO30
: Contributions include not only source code, but also documentation,
  constructive bug reports, constructive discussions, marketing and generally
  anything that adds value to the project.

  ?

CO40
: The community is meritocratic and over time aims to give more rights and
  responsibilities to contributors who add value to the project.

  ?

CO50
: The way in which contributors can be granted more rights such as commit
  access or decision power is clearly documented and is the same for all
  contributors.

  ?

CO60
: The community operates based on consensus of its members (see CS10) who have
  decision power. Dictators, benevolent or not, are not welcome in Apache
  projects.

  ?

CO70
: The project strives to answer user questions in a timely manner.

  ?

Consensus Building
------------------

CS10
: The project maintains a public list of its contributors who have decision
  power -- the project's PMC (Project Management Committee) consists of those
  contributors.

  ?

CS20
: Decisions are made by consensus among PMC members and are documented on the
  project's main communications channel. Community opinions are taken into
  account but the PMC has the final word if needed.

  ?

CS30
: Documented voting rules are used to build consensus when discussion is not
  sufficient.

  ?

CS40
: In Apache projects, vetoes are only valid for code commits and are justified
  by a technical explanation, as per the Apache voting rules defined in CS30.

  ?

CS50
: All "important" discussions happen asynchronously in written form on the
  project's main communications channel. Offline, face-to-face or private
  discussions that affect the project are also documented on that channel.

  ?

Independence
------------

IN10
: The project is independent from any corporate or organizational influence.

  ?

IN20
: Contributors act as themselves as opposed to representatives of a corporation
  or organization.

  ?

