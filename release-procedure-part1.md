---
layout: page 
title: Beginning the release process
permalink: /release-procedures-part1/
---

* Table of contents
{:toc}

Create a discussion thread for the release {#discuss-thread}
------------------------------------------------------------

Beginning a new release candidate should not be a unilateral decision. There is
no requirement that an official vote be held prior to starting a release
candidate, but there needs to be some discussion via a `[DISCUSS]` thread on
<dev@guacamole.apache.org> to gauge whether the time is right for a release.

Development of Apache Guacamole is not halted when a release is being prepared,
but the main development tree is forked. With this in mind, it is best to only
begin the release process when:

 * The development community agrees (or, more likely, doesn't disagree) that
   the scope of the release can be finalized (no new features/fixes/etc. will
   be considered for the release).
 * The non-release development line is unlikely to diverge so far from the
   release development line that it is detrimental to the project.

All issues which should be part of the release must be tagged as such within
JIRA (their "Fix Version" field should point to the release).

Example: [the [DISCUSS] thread for 0.9.11-incubating](http://mail-archives.apache.org/mod_mbox/incubator-guacamole-dev/201701.mbox/%3CCALKeL-OO7MMpvtZkFXbkrkRKVokKHgdANTpMVceaH41MnUu7Eg%40mail.gmail.com%3E)

Create the release branch {#release-branch}
-------------------------------------------

When a release has been decided, release-specific branches need to be created
to isolate the development line of the release from that of the main `master`
branch. This allows development on `master` to continue, while allowing the
contents of the release to remain within the agreed scope.

Create a new `staging/[VERSION]` branch for each of the following repositories,
where `[VERSION]` is the version of the upcoming release, such as
"0.9.11":

 * [`guacamole-client`](https://github.com/apache/guacamole-client)
 * [`guacamole-server`](https://github.com/apache/guacamole-server)
 * [`guacamole-manual`](https://github.com/apache/guacamole-manual)

Note that *the
[`guacamole-website`](https://github.com/apache/guacamole-website)
repository does not get a release branch*. The website points to release
artifacts, etc. but is not itself part of the release.

Once the release branch is made, all release-specific changes must be made
against the release branch *only*. Pull requests for changes related to the
release must be merged directly to the release branch, with the release branch
continually merged back to `master` with each such change.


Bump version numbers {#bump-version}
------------------------------------

The version numbers of Apache Guacamole's various components do not get bumped
until a release is being prepared. With the exception of any in-scope changes
which are in-progress (which should usually be minimal), bumping the version
numbers is one of the final development steps before the first release
candidate.

Only the version numbers of modified components should be bumped. That said,
bumping the version numbers of some components will result in their
dependencies being modified, and thus bumped as well. For example:

 * If `guacamole-ext` is modified, all extensions and `guacamole` itself will
   need to depend on the new version of `guacamole-ext`.
 * If `guacamole` is modified (this has been the case for all past releases),
   all extensions will need to be modified to specify the correct version
   number in their `guac-manifest.json`.

### Bumping the version of `guacamole-server`

The main locations which need modification within `guacamole-server`
are:

 * `configure.ac`
 * `doc/Doxyfile` (if libguac has been modified)
 * libtool version-info within `src/libguac/Makefile.am` (if libguac has been 
   modified)
 * `bin/guacctl`
 * The manpages for `guacd`, `guacenc`, and `guacd.conf`.

Example: [the pull request for bumping `guacamole-server` to 0.9.11-incubating](https://github.com/apache/guacamole-server/pull/34)

### Bumping the version of `guacamole-client`

The main locations which need modification within `guacamole-client`
are:

 * The `pom.xml` of any modified project, as well as any project which depends
   on a modified project (and is thus modified itself). **Don't forget the
   example project in `doc/guacamole-example`!**
 * The `guac-manifest.json` of any extension.
 * The `Guacamole.API_VERSION` value declared within `Version.js` (if
   `guacamole-common-js` has been modified).

Example: [the pull request for bumping `guacamole-client` to 0.9.11-incubating](https://github.com/apache/guacamole-client/pull/103)

### Updating `guacamole-manual` accordingly

The manual (`guacamole-manual`) will also need to be updated to point
to the latest versions of everything. In most cases, this involves simply
replacing the old version number with the new version number wherever it
occurs, but the process needs to be selective if not all components have been
modified. In particular, watch out for:

 * The need to document new database schema upgrade scripts.
 * The need to update the webapp, authentication, and protocol plugin
   tutorials.

Example: [the pull request for bumping `guacamole-manual` to 0.9.11-incubating](https://github.com/apache/guacamole-manual/pull/23)

