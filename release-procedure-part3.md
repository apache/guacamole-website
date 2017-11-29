---
layout: page 
title: Promoting a release candidate to release
permalink: /release-procedures-part3/
---

* Table of contents
{:toc}

Delete the release branch {#delete-branch}
------------------------------------------

Once [the PMC vote](/release-procedures-part2/#pmc-vote) for the release has
passed, the release branches [which were created
previously](/release-procedures-part1/#release-branch) must be deleted.
Assuming they were properly merged back to `master` as release-specific changes
were made, deleting these branches with `git branch -d` will succeed without
warnings. If git refuses to delete the branches because commits are missing
from `master`, **something is horribly wrong, and the release needs to be
rechecked**.

    $ git checkout master
    $ git branch -d staging/0.9.11
    $ git push upstream :staging/0.9.11

Tag the final version of the release {#final-tag}
-------------------------------------------------

The specific point in the git history that the release was made must be marked
with a new tag, pointing to the exact same commit as the last [tagged release
candidate](/release-procedures-part2/#tag-rc). This tag must be made in the
format `[VERSION]`, where `[VERSION]` is the version of the release:

    $ git tag -m "Release 0.9.11." 0.9.11
    $ git push upstream 0.9.11

Just as with release candidates, each repository relevant to the release must
be tagged. This will be every repository that had a release branch (the release
branch having been [deleted earlier](#delete-branch)) and *never* includes
`guacamole-website`, which is not part of the release.

Example: [the "0.9.10-incubating" tag on
guacamole-server](https://git1-us-west.apache.org/repos/asf?p=guacamole-server.git;a=tag;h=0875ca8f4e86b942b466cfebf84cc33c47095130)


Upload final release artifacts {#final-upload}
----------------------------------------------

### Artifacts in dist SVN

The release artifacts and their signatures come from the release candidate
which was approved via the VOTE. These artifacts are already present in the SVN
dist area under `dev/`, and need to be moved to the analogous area under
`release/`. *This must be done using `svn mv`*, with the directory containing
the artifacts and signatures being renamed from `[VERSION]-RC[N]` to
`[VERSION`] in the process.

    $ svn mv dev/guacamole/0.9.11-RC1 release/guacamole/0.9.11
    $ svn commit -m "Promote Apache Guacamole 0.9.11-RC1 artifacts to 0.9.11 release."

Note that, once this has finished, **YOU MUST STILL WAIT AT LEAST 24 HOURS TO
ALLOW THE [MIRRORS](https://www.apache.org/mirrors/) TIME TO SYNC** before
announcing the release.

### Maven artifacts

For the Maven artifacts to become generally available at
<https://repository.apache.org/>, and for those artifacts to be synced with
[Maven Central](https://search.maven.org/), the staging repository [created and
closed earlier](/release-procedures-part2/#staging-maven) needs to be
explicitly released using [Apache's Nexus
instance](https://repository.apache.org/). Doing this involves simply selecting
the repository, clicking the "release" button, and typing a reasonable log
message noting the release.

Note that it may take a day or so for Maven Central to contain the new
artifacts, just like the mirrors, but absence of artifacts from Maven Central
does not block announcement of the release as long as they are confirmed to be
present on <https://repository.apache.org/>.

### Docker images

Both the `guacamole/guacamole` and `guacamole/guacd` images should now be
updated with a new version-specific tag, duplicated to the `latest` tag. Since
the images deployed for past release candidates were first cleaned with
`git clean`, nothing should be actually rebuilt as a consequence of running
`docker build` unless something has gone wrong and source changes were made
in the absence of an RC.

For example, to build the `guacamole/guacamole` Docker image for the current
release candidate, from within the top-level `guacamole-client` directory:

    $ git clean -xfd .
    $ sudo docker build -t guacamole/guacamole:0.9.11 .
    $ sudo docker build -t guacamole/guacamole:latest .

Each of the above commands should finish virtually instantaneously, and the
hash of the built images should match each other and the previous RC. Assuming
all looks well, it should be safe to push the images:

    $ sudo docker push guacamole/guacamole:0.9.11
    $ sudo docker push guacamole/guacamole:latest

Again, this should finish virtually instantaneously, as no new data will need
to be pushed. Docker Hub already has the images/layers from the previous RC
builds.

