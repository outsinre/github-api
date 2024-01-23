# Clone This Repo

Clone this repo and add it to environment variable `PATH`.

```bash
~ $ git clone git@github.com:outsinre/release-helper.git
~ $ cd release-helper
~ $ chmod +x verify-prs

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
~ $ verify-prs -h

~ $ verify-prs --org-repo kong/kong-ee --base-commit 2.8.4.5 --head-commit 2.8.4.6
Org Repo: kong/kong
Base Commit: 3.5.0
Head Commit: HEAD

comparing between '3.5.0' and 'HEAD'
number of commits: 280
number of pages: 6
commits per page: 50

PRs:
https://github.com/Kong/kong-ee/pull/7414
...

PRs without changelog:
https://github.com/Kong/kong-ee/pull/7413
...

PRs without cherry-pick label:
https://github.com/Kong/kong/pull/11304

commits: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/output.K35ATb9k/commits.txt
pull requests: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/output.K35ATb9k/prs.txt
pull requests without changelog: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/output.K35ATb9k/no_changelog_prs.txt
pull requests without cherry-pick: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/output.K35ATb9k/no_cherrypick_prs.txt

Remeber to remove /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/output.K35ATb9k
```
