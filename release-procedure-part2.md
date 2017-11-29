---
layout: page 
title: Producing a release candidate
permalink: /release-procedures-part2/
---

* Table of contents
{:toc}

Tag the release candidate {#tag-rc}
-----------------------------------

Once [the release process has begun](/release-procedures-part1/) and the
release has been **thoroughly tested**, the git repositories must be tagged for
a new release candidate. These tags are made off the release branch (*not* off
`master`), and are in the format `[VERSION]-RC[N]`, where `[VERSION]` is the
version of the upcoming release and `[N]` is the number of the release
candidate:

    $ git tag -m "Release 0.9.11 - RC1." 0.9.11-RC1
    $ git push upstream 0.9.11-RC1

Each repository relevant to the release must be tagged. At this point, this
will be every repository that has a release branch. This *never* includes
`guacamole-website`, which is not part of the release.

Example: [the
"0.9.10-incubating-RC3" tag on
guacamole-server](https://git1-us-west.apache.org/repos/asf?p=guacamole-server.git;a=tag;h=6c2bc47a93899cf00a869e7a2a5416fd5b081ed3)


Sign and upload release artifacts {#upload-rc}
----------------------------------------------

Create and sign release artifacts for all modified components, uploading to
Apache's dev dist via SVN (*NOT* the release dist), grouping the artifacts
within `binary/` and `source/` subdirectories of a top-level, RC-specific
subdirectory (named in the same `[VERSION]-RC[N]` format as the [repository
tag](#tag-rc)).

Creating the source and binary artifacts involves building the components of
Guacamole normally. The process for producing signatures and uploading the
artifacts will depend on whether the artifacts are being deployed to a Maven
repository.

**If your PGP key is not already present in the `KEYS` file, you will need to
add it prior to signing artifacts.**

### Normal source / binary artifacts {#artifacts}

There are currently two source artifacts:

 * `guacamole-client-[VERSION].tar.gz`
 * `guacamole-server-[VERSION].tar.gz`

`guacamole-client-[VERSION].tar.gz` is created automatically when
`guacamole-client` is built with `mvn clean install`.
`guacamole-server-[VERSION].tar.gz` can be built manually by running `make
dist` within `guacamole-server`. The `Makefile`, etc. will need to
have been generated first by running `autoreconf -fi` followed by
`./configure`.

`guacamole-server` does not provide any convenience binaries, but
`guacamole-client` does:

 * `guacamole-[VERSION].war`
 * `guacamole-auth-duo-[VERSION].tar.gz`
 * `guacamole-auth-header-[VERSION].tar.gz`
 * `guacamole-auth-jdbc-[VERSION].tar.gz`
 * `guacamole-auth-ldap-[VERSION].tar.gz`
 * `guacamole-auth-noauth-[VERSION].tar.gz`

Each of the above can be found within the `guacamole-client` source
tree once it has been built with `mvn clean install`.

Producing the required MD5 and SHA256 checksums for a given artifact is very
straightforward:

    $ md5sum FILENAME > FILENAME.md5
    $ sha256sum FILENAME > FILENAME.sha

To produce the PGP signature for a given artifact, use `gpg`, as documented in
Apache's own [release signing documentation](https://www.apache.org/dev/release-signing.html#openpgp-ascii-detach-sig):

    $ gpg --armor --output FILENAME.asc --detach-sig FILENAME

Example: [the SVN commit uploading RC1 of 0.9.10-incubating (r17053)](https://dist.apache.org/repos/dist/dev/incubator/guacamole/?p=17053)

### Maven artifacts {#staging-maven}

The following Maven subprojects of `guacamole-client` must be
uploaded to Apache's Nexus:

 * `guacamole-common` (`.jar`, source, and javadoc)
 * `guacamole-common-js` (`.zip` only)
 * `guacamole-ext` (`.jar`, source, and javadoc)

Uploading to [Apache's Nexus repository](https://repository.apache.org/)
requires that your username and password be stored within your Maven
`~/.m2/settings.xml`:

    <settings>
        <servers>
            <server>
                <id>apache</id>
                <username>YOUR-USERNAME</username>
                <password>YOUR-PASSWORD</password>
            </server>
        </servers>
    </settings>

The ID of the server is arbitrary but must match the `repositoryId` value given
to Maven. The examples here use `apache`. Most artifacts are Java `.jar` files
with corresponding JavaDoc and source jars. Each of these must be signed and
uploaded individually using the `gpg:sign-and-deploy-file` mojo:

    $ mvn gpg:sign-and-deploy-file \
        -Durl=https://repository.apache.org/service/local/staging/deploy/maven2 \
        -DrepositoryId=apache -DpomFile=guacamole-common/pom.xml \
        -Dfile=guacamole-common/target/guacamole-common-0.9.10.jar

    $ mvn gpg:sign-and-deploy-file \
        -Durl=https://repository.apache.org/service/local/staging/deploy/maven2 \
        -DrepositoryId=apache -DpomFile=guacamole-common/pom.xml \
        -Dfile=guacamole-common/target/guacamole-common-0.9.10-javadoc.jar \
        -Dclassifier=javadoc

    $ mvn gpg:sign-and-deploy-file \
        -Durl=https://repository.apache.org/service/local/staging/deploy/maven2 \
        -DrepositoryId=apache -DpomFile=guacamole-common/pom.xml \
        -Dfile=guacamole-common/target/guacamole-common-0.9.10-sources.jar \
        -Dclassifier=sources

The above will need to be done for both `guacamole-common` and `guacamole-ext`,
assuming both have been modified for the release. For JavaScript artifacts like
`guacamole-common-js` which produce a single `.zip` file, only the `.zip` file
needs to be uploaded. The command for this is slightly different:

    $ mvn gpg:sign-and-deploy-file \
        -Durl=https://repository.apache.org/service/local/staging/deploy/maven2 \
        -DrepositoryId=apache \
        -DpomFile=guacamole-common-js/pom.xml \
        -Dfile=guacamole-common-js/target/guacamole-common-js-0.9.10.zip \
        -Dpackaging=zip

Once everything has been uploaded, log into Apache's Nexus at
https://repository.apache.org/, locate the staging repository which was
automatically created, and verify things look as expected. Assuming everything
looks good, select close staging repository to make it publicly available; the
URL of the repository will need to be provided in the VOTE email.

### Docker images

Both guacamole-client and guacamole-server have associated Docker images which
are produced along with releases as a form of convenience binaries. These
images are `guacamole/guacamole` and `guacamole/guacd` respectively, both
hosted under the Apache Guacamole project's [Docker Hub
account](https://hub.docker.com/u/guacamole/).

When building the Docker images, keep in mind:

1. You should run `git clean -xfd .` first, to ensure the build context
   uploaded to the Docker daemon is minimal, and that future builds of the
   exact same source will not result in different images (this serves as a
   pre-release sanity check).
2. You **MUST NOT** update the `latest` tag on Docker Hub, as this must only
   point to the latest stable release.
3. When building a Docker image with the intent of pushing to a specific tag,
   the Docker image must be built with that tag.

For example, to build the `guacamole/guacamole` Docker image for the current
release candidate, from within the top-level `guacamole-client`
directory:

    $ git clean -xfd .
    $ sudo docker build -t guacamole/guacamole:0.9.11-RC1 .
    $ sudo docker push guacamole/guacamole:0.9.11-RC1


Upload documentation and release notes {#upload-docs}
-----------------------------------------------------

The draft release notes and updated documentation both need to be uploaded to
the website prior to [calling the PMC vote](#pmc-vote). These changes should
be handled like any other website changes - via pull requests against the
`guacamole-website` repository. **DO NOT UPDATE THE TOP-LEVEL
DOCUMENTATION SYMBOLIC LINKS!** The top-level symbolic links in the `doc/`
directory of `guacamole-website` point to the documentation for the
latest release, and are thus only updated once the release is complete.

Take a look at past release notes to get an idea for the expected format. There
is no hard-set requirement for the format of release notes, but things should
be as consistent as possible. Use JIRA to query the issues which have been
completed for the release, manually excluding issues which relate only to
other issues already in the release (bug fixes for a release-specific change,
for example).

Because the script that handles updating project websites often fails to update
for large commits (see [INFRA-10751](https://issues.apache.org/jira/browse/INFRA-10751)), uploading documentation first, waiting a bit, and *then* uploading
the release notes has a greater chance of working. Splitting the two uploads
also helps facilitate code review, as the release notes will be buried in a sea
of auto-generated HTML otherwise.

Examples:

 * [The draft
release notes for 0.9.10-incubating-RC3](https://github.com/apache/guacamole-website/blob/67adf0802701d696f9dc1a90229da694f4cebbaa/_releases/0.9.10-incubating.md)
 * [The updated documentation for 0.9.10-incubating](https://github.com/apache/guacamole-website/tree/master/doc/0.9.10-incubating)

Create the PMC `[VOTE]` thread {#ppmc-vote}
-------------------------------------------

Once the above has been completed, request a vote with an email to
<dev@guacamole.apache.org> titled `[VOTE] Release Apache Guacamole [VERSION]
(RC[N])`, containing the following:

```
Hello all,

The [NTH] release candidate for Apache Guacamole [VERSION] has been
uploaded and is ready for VOTE. The draft release notes (along with links
to artifacts, signatures/checksums, and updated documentation) can be found
here:

http://guacamole.apache.org/releases/[VERSION]/

The git tag for all relevant repositories is "[VERSION]-RC[N]":

https://github.com/apache/guacamole-client/tree/[VERSION]-RC[N]
https://github.com/apache/guacamole-server/tree/[VERSION]-RC[N]
https://github.com/apache/guacamole-manual/tree/[VERSION]-RC[N]

Build instructions are included in the manual, which is part of the updated
documentation referenced above. For convenience:

http://guacamole.apache.org/doc/[VERSION]/gug/installing-guacamole.html

Maven artifacts for guacamole-common, guacamole-common-js, and
guacamole-ext can be found in the following staging repository:

[STAGING REPOSITORY URL]

Source and binary distributions (also linked within the release notes):

https://dist.apache.org/repos/dist/dev/guacamole/[VERSION]-RC[N]/

Artifacts have been signed with the "[EMAIL]" key listed in:

https://dist.apache.org/repos/dist/dev/guacamole/KEYS

Please review and vote:

[ ] +1 Approve the release
[ ] -1 Don't approve the release (please provide specific comments)

This vote will be open for at least 72 hours.

Here is my +1.

Thanks,

[YOU]
```

Where `[VERSION]` is the release version, `[N]` and `[NTH]` are the number of
the release candidate, `[STAGING REPOSITORY URL]` is the URL of [the staging
repository created earlier](#staging-maven), `[EMAIL]` is the email address
associated with the PGP key used to sign the release artifacts, and `[YOU]` is
your name.  Obviously, alter the email as necessary if the scope of the release
is different.

Please note that, though community input is welcome, *only PMC votes count
toward the required three "+1" votes*.

Example: [the 0.9.10-incubating-RC3 PPMC VOTE email](http://mail-archives.apache.org/mod_mbox/incubator-guacamole-dev/201612.mbox/%3CCALKeL-PKQxOYqZCvhH6_ZF33Zo_LUZjLVZzTh%2B0VRipgsNxQ1g%40mail.gmail.com%3E)

If any release-blocking issues are discovered, the vote must be canceled and
development must resume, followed by another release candidate (prepared as
above) intended to address those issues.

