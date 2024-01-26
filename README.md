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

Given two arbitrary revisions, list commits, PRs, PRs without changelog and PRs without CE2EE.

If a CE PR has neither the 'cherry-pick kong-ee' label nor has cross-referenced EE PRs with 'cherry'
in the title, it is HIGHLY PROBABLY not synced to EE. This is only experimental as developers may not
follow the CE2EE guideline. However, it is a quick shortcut for us to validate the majority of CE PRs.

Ensure `GITHUB_TOKEN` is set in your environment.

```bash
~ $ echo $GITHUB_TOKEN
```

Run the script. Both `--base-commit` and `--head-commit` can be set to branch names.

```bash
~ $ verify-prs -h
Version: 0.1
 Author: Zachary Hu (zhucac AT outlook.com)
 Script: Compare between two revisions (e.g. tags and branches), and output
         commits, PRs, PRs without changelog and
         optionally CE PRs without CE2EE (experimental).

  Usage: verify-prs -h

         -v, --verbose       Print debug info.

         --strict-filter     When checking if a CE PR is synced to EE or not,
                             more strict filters are applied

         --bulk N            Number of jobs ran concurrency. Default is 5.
                             Adjust this value to your CPU cores.

         verify-prs --org-repo kong/kong-ee --base-commit 3.4.2.0 --head-commit 3.4.2.1 [--strict-filter] [--bulk 5] [-v]

         ORG_REPO=kong/kong-ee BASE_COMMIT=3.4.2.0 HEAD_COMMIT=3.4.2.1 verify-prs

~ $ verify-prs --org-repo kong/kong --base-commit 3.4.0 --head-commit 3.5.0
Org Repo: kong/kong
Base Commit: 3.4.0
Head Commit: 3.5.0

comparing between '3.4.0' and '3.5.0'
number of commits: 280
number of pages: 6
commits per page: 50

PRs:
https://github.com/Kong/kong/pull/7414
...

PRs without changelog:
https://github.com/Kong/kong/pull/7413
...

PRs without 'cherry-pick kong-ee' label:
https://github.com/Kong/kong/pull/11721
...

PRs without cross-referenced EE PRs:
https://github.com/Kong/kong/pull/11304
...

Commits: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/outputXXX.JEkGD8AO/commits.txt
PRs: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/outputXXX.JEkGD8AO/prs.txt
PRs without changelog: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/outputXXX.JEkGD8AO/prs_no_changelog.txt
CE PRs without cherry-pick label: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/outputXXX.JEkGD8AO/prs_no_cherrypick_label.txt
CE PRs without referenced EE cherry-pick PRs: /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/outputXXX.JEkGD8AO/prs_no_cross_reference.txt

Remeber to remove /var/folders/wc/fnkx5qmx61l_wx5shysmql5r0000gn/T/outputXXX.JEkGD8AO
```
