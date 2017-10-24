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

  **OK:** Each Apache Guacamole release consists of two `.tar.gz` source
  archives (for "guacamole-client" and "guacamole-server" respectively).
  Binaries are provided only as a convenience. See [the 0.9.13-incubating
  release notes](/releases/0.9.13-incubating/).

RE20
: Releases are approved by the project's PMC (see CS10), in order to make them
  an act of the Foundation.

  **OK:** Each release candidate must pass a corresponding VOTE before it can
  be promoted to a release, [as documented in our release
  procedures](/release-procedures-part2/#ppmc-vote). For example, see [the
  archived VOTE RESULT for the 0.9.13-incubating
  release](https://lists.apache.org/thread.html/191c32b9ca2e62fe75cdc8df414bae949875550e57cf6b6014832829@%3Cdev.guacamole.apache.org%3E).

RE30
: Releases are signed and/or distributed along with digests that can be
  reliably used to validate the downloaded archives.

  **OK:** All release artifacts are signed and distributed with corresponding
  signatures and checksums as defined by [the relevant section of our release
  procedures](/release-procedures-part2/#upload-rc). See [the 0.9.13-incubating
  release notes](/releases/0.9.13-incubating/).

RE40
: Convenience binaries can be distributed alongside source code but they are
  not Apache Releases -- they are just a convenience provided with no
  guarantee.

  **OK:** Convenience binaries are linked within the release notes of each
  release with prominent wording noting that they are provided for convenience.
  See [the 0.9.13-incubating release notes](/releases/0.9.13-incubating/).

RE50
: The release process is documented and repeatable to the extent that someone
  new to the project is able to independently generate the complete set of
  artifacts required for a release.

  **OK:** The [release process](/open-source/#release-procedures) is fully
  documented from start to finish:

   * [Beginning the release process](/release-procedures-part1/)
   * [Producing a release candidate](/release-procedures-part2/)
   * [Promoting a release candidate to release](/release-procedures-part3/)
   * [Announcing the release](/release-procedures-part4/)

Quality
-------

QU10
: The project is open and honest about the quality of its code. Various levels
  of quality and maturity for various modules are natural and acceptable as
  long as they are clearly communicated.

  **OK:** Changes are only accepted after passing code review. All code is
  required to be thoroughly documented and commented, and these requirements
  are [published on the project website](/guac-style/).

QU20
: The project puts a very high priority on producing secure software.

  **OK:** The project follows strict code review policies, and the website
  provides a prominent "Security" link in the navigation menu pointing to the
  ASF's documentation on properly reporting security issues. Any report of
  a possible issue with security implications is handled with priority via
  private channels.

QU30
: The project provides a well-documented, secure and private channel to report
  security issues, along with a documented way of responding to them.

  **OK:** The project provides the <private@guacamole.incubator.apache.org>
  mailing list for security issues. These procedures are documented in the
  ASF's own security documentation, which is linked within the project
  website's navigation menu.

QU40
: The project puts a high priority on backwards compatibility and aims to
  document any incompatible changes and provide tools and documentation to help
  users transition to new features.

  **OK:** Any changes in a release which affect compatibility are noted in the
  release notes. Where possible, old functionality is maintained but
  deprecated. See [the "deprecation / compatibility notes" section of the
  0.9.13-incubating release](/0.9.13-incubating/#deprecation--compatibility-notes).

QU50
: The project strives to respond to documented bug reports in a timely manner.

  **OK:** Yes, via JIRA.

Community
---------

CO10
: The project has a well-known homepage that points to all the information
  required to operate according to this maturity model.

  **OK:** The project's homepage is <http://guacamole.incubator.apache.org>.

CO20
: The community welcomes contributions from anyone who acts in good faith and
  in a respectful manner and adds value to the project.

  **OK:** All contributors willing to work with the community are welcome.
  Contributions are only ever rejected for technical reasons.

CO30
: Contributions include not only source code, but also documentation,
  constructive bug reports, constructive discussions, marketing and generally
  anything that adds value to the project.

  **OK:** Participation within the mailing lists and JIRA is active and
  encouraged. The community can contribute to the documentation and website
  just as they can contribute to the code of the project.

CO40
: The community is meritocratic and over time aims to give more rights and
  responsibilities to contributors who add value to the project.

  **OK:** The community's meritocratic nature is [documented on the project
  website](/open-source/#meritocracy). Through operating in this fashion, the
  project has grown over the course of its incubation from its original two
  committers to five.

CO50
: The way in which contributors can be granted more rights such as commit
  access or decision power is clearly documented and is the same for all
  contributors.

  **OK:** See CO40.

CO60
: The community operates based on consensus of its members (see CS10) who have
  decision power. Dictators, benevolent or not, are not welcome in Apache
  projects.

  **OK:** Decisions affecting the project are made only on the mailing lists
  through discussions and VOTEs.

CO70
: The project strives to answer user questions in a timely manner.

  **OK:** Yes, via the mailing lists.

Consensus Building
------------------

CS10
: The project maintains a public list of its contributors who have decision
  power -- the project's PMC (Project Management Committee) consists of those
  contributors.

  **OK:** This list is automatically produced by people.apache.org and can be
  found at: <http://people.apache.org/committers-by-project.html#guacamole>.

CS20
: Decisions are made by consensus among PMC members and are documented on the
  project's main communications channel. Community opinions are taken into
  account but the PMC has the final word if needed.

  **OK:** All decisions affecting the project are made on the mailing lists
  (see CO60) and are inherently documented through the mail archives.
  Development itself is documented in JIRA.

CS30
: Documented voting rules are used to build consensus when discussion is not
  sufficient.

  **OK:** Discussion has always been sufficient. If/when consensus cannot be
  reached via discussion, voting is the next logical step.

CS40
: In Apache projects, vetoes are only valid for code commits and are justified
  by a technical explanation, as per the Apache voting rules defined in CS30.

  **OK:** The project has never used vetoes.

CS50
: All "important" discussions happen asynchronously in written form on the
  project's main communications channel. Offline, face-to-face or private
  discussions that affect the project are also documented on that channel.

  **OK:** All decisions affecting the project are made on the mailing lists
  (see CO60).

Independence
------------

IN10
: The project is independent from any corporate or organizational influence.

  **OK:** Project members operate as individuals, not representatives of any
  organization (corporate or otherwise). Though the project members were
  originally all affiliated with the same organization, the project has grown
  and this is no longer the case (see CO40).

IN20
: Contributors act as themselves as opposed to representatives of a corporation
  or organization.

  **OK:** See IN10.

