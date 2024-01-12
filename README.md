# Retrieve PRs

Use GitHub REST API to retrieve commits, PRs and PRs without changelog between two arbitrary revisions.

```bash
~ $ chmod +x release-prs.sh
~ $ ./release-prs.sh -h

~ $ ./release-prs.sh --org-repo kong/kong-ee --base-commit 3.4.3.2 --head-commit next/3.4.x.x
```
