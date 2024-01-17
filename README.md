# Clone This Repo

Clone this repo and add it to environment variable `PATH`.

```bash
~ $ git clone git@github.com:outsinre/release-helper.git
~ $ cd release-helper
~ $ chmod +x verify-changelog

~ $ PATH="$(realpath .):$PATH"
```

# Generate Changelog

Enure `golang` is available on your local system.

```bash
~ $ go env
```

Get into the local repo directory, and run commands below.

## Generate EE changelog

```bash
~ $ pwd
/Users/zachary/workspace/kong-ee

~ $ make -f ~/workspace/release-helper/Makefile CHANGELOG_VERSION=3.6.0.0 generate-ee

~ $ git mv changelog/unreleased changelog/3.6.0.0
~ $ mkdir -p changelog/unreleased/{kong,kong-ee,kong-manager-ee,kong-portal}
~ $ touch changelog/unreleased/{kong,kong-ee,kong-manager-ee,kong-portal}/.gitkeep

~ $ git add .
~ $ git commit -m "docs(release): genereate 3.6.0.0 changelog"
```

## Generate CE changelog

Please do not cherry-pick this PR to EE side.

```bash
~ $ pwd
/Users/zachary/workspace/kong

~ $ make -f ~/workspace/release-helper/Makefile CHANGELOG_VERSION=3.6.0 generate-ce

~ $ git mv changelog/unreleased changelog/3.6.0
~ $ mkdir -p changelog/unreleased/{kong,kong-manager}
~ $ touch changelog/unreleased/{kong,kong-manager}/.gitkeep

~ $ git add .
~ $ git commit -m "docs(release): genereate 3.6.0 changelog"
```

# Retrieve PRs

Given two arbitrary revisions, list commits, PRs and PRs without changelog.

```bash
~ $ verify-changelog -h

~ $ verify-changelog --org-repo kong/kong-ee --base-commit 2.8.4.5 --head-commit next/2.8.x.x
Org Repo: kong/kong-ee
Base Commit: 2.8.4.5
Head Commit: next/2.8.x.x
Comparing between '2.8.4.5' and 'next/2.8.x.x'
Number of commits: 20

PR list:
https://github.com/Kong/kong-ee/pull/7414
...

PRs without changelog:
https://github.com/Kong/kong-ee/pull/7413
...
```
