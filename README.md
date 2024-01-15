# Retrieve PRs

Use GitHub REST API to retrieve commits, PRs and PRs without changelog between two arbitrary revisions.

```bash
~ $ chmod +x verify-changelog.sh
~ $ ./verify-changelog.sh -h

~ $ ./verify-changelog.sh --org-repo kong/kong-ee --base-commit 2.8.4.5 --head-commit next/2.8.x.x
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
