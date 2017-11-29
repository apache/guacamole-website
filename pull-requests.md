---
layout: page 
title: Managing Pull Requests
permalink: /pull-requests/
---

The Apache Guacamole project requires code review for absolutely all changes,
and uses pull requests to facilitate that review. However, because pull 
requests must be made against the read-only mirrors on GitHub, merging is
slightly more complicated.

There is no "merge" button. Merges must be performed manually and pushed to the
main repositories which live at the ASF. Once pushed, a robot running at the
ASF (which has write access to the GitHub mirrors) will automatically close
the pull request as merged.

You will need three remotes for each Apache Guacamole git repository:

1. The upstream repository hosted by the ASF's servers
2. The GitHub mirror
3. Your personal fork of the GitHub mirror

For the sake of simplicity, these will be referred to here as `upstream`,
`mirror`, and `origin`, respectively. For example, the recommended
configuration for `guacamole-server` would be:

    $ git remote -v
    mirror git@github.com:apache/guacamole-server.git
    origin git@github.com:mike-jumper/guacamole-server.git
    upstream https://git-wip-us.apache.org/repos/asf/guacamole-server.git
    $

After reviewing and approving code submitted via a pull request, you will need
to:

1. Manually fetch the contents of the pull request to a new branch via the
   command line:

       $ git fetch mirror pull/NUMBER/head:some-branch

   where `NUMBER` is the pull request number and `some-branch` is a sensible
   branch name of your choice.

2. Ensure your copy of the base branch is up to date, whether that be `master`
   or the staging branch for an upcoming release:

       $ git fetch upstream
       $ git checkout master
       $ git merge --ff-only upstream/master
       $ git push origin

3. Merge the branch containing the changes from the pull request:

       $ git merge --no-ff some-branch

   **Be sure to specify `--no-ff`!** Merges of pull requests must have
   corresponding merge commits, and the messages of those merge commits must
   properly tag the associated JIRA issue (just like all other commits).

4. Confirm that the changes look as expected:

       $ git diff upstream/master

5. Push the merge result to the ASF repository:

       $ git push upstream master

   You will be prompted for your username (Apache ID) and password. It is
   highly recommended that you not save/cache your credentials for this step,
   as it serves as an additional sanity check preventing accidental pushes to
   the main repository.

Once this is done, the ASF git bot should kick in, and emails should go out
across the <commits@guacamole.apache.org> list noting each commit
pushed. If this does not happen, or the commits show up only within the ASF
repositories and not the GitHub mirrors, it may be necessary to reach out to
[Infra](https://www.apache.org/dev/infrastructure.html) by opening an issue
against [the "Infrastructure" project in
JIRA](https://issues.apache.org/jira/browse/INFRA/).

Merging release-specific changes
--------------------------------

When a pull request is intended for a pending release, the merge base specified
in the pull request *should* be the staging branch for that release. That said,
part of the point of code review is to identify mistakes prior to merge, and
using the wrong base for a release-specific change is one of those mistakes. It
is good practice to verify whether a staging branch for the release exists in
the main ASF repository, and to double-check whether the change in question is
associated with a release-specific change by checking the "Fix Version" field
for the issue in JIRA.

Merging release-specific changes involves:

1. Merging the pull request to the **staging branch**. The steps for doing this
   are exactly as described above, except you will need to specify
   `staging/VERSION` instead of `master`.

2. Merging the **staging branch** to **`master`**. Doing this is largely the
   same as described above, except that there is inherently no JIRA issue to
   tag in the commit message. A message like "Merging 0.9.10 changes back to
   master." is pretty sensible.

   **DO NOT MERGE THE PULL REQUEST TO MASTER DIRECTLY!** The point of merging
   the staging branch to master rather than the pull request is to ensure that
   the git history reflects that all commits to the staging branch are present
   on `master`. If the pull request is merged to master directly, then the git
   history ends up with two distinct merges and two distinct sets of commits,
   and final release sanity checks performed prior to deleting the staging
   branch will fail.

