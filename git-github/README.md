# Git and GitHub Practice

This section demonstrates two commonly misunderstood workflows without adding artificial commits to the homework repository.

- [`git commit -a -m`](commit-a-vs-commit-m.md): tracked modifications/deletions are staged automatically; untracked files are not.
- [Cherry-pick](cherry-pick.md): copy one selected commit's change onto another branch.

Run the safe, disposable demonstration:

```bash
chmod +x git-practice-demo.sh
./git-practice-demo.sh
```

The script creates a unique directory below `${TMPDIR:-/tmp}`, configures a local-only demo identity, initializes `main`, makes meaningful commits, creates `feature-demo`, cherry-picks one feature commit, proves its file exists, and removes the temporary repository on exit. It does not alter this project's Git history or global Git configuration.
