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

## Objective and task coverage

This section meets both Git tasks: it demonstrates `git commit -m` versus `git commit -a -m` (tracked modifications/deletions are staged, brand-new files are not) and performs a reproducible cherry-pick from a feature branch onto `main`. The temporary repository contains three meaningful main commits, two feature commits, a real selected hash, a graph, content verification, and final status output.

## Reproduce and evidence

```bash
chmod +x git-practice-demo.sh
./git-practice-demo.sh
```

The genuine transcript is [git-practice-output.txt](../evidence/command-outputs/git-practice-output.txt). It prints the before/after `commit -a` status, a runtime-generated selected commit hash, `git log --oneline --graph --all --decorate`, the cherry-picked content, and final status. Terminal screenshot slots 04 and 05 are listed in [`evidence/screenshots/README.md`](../evidence/screenshots/README.md); no PNG is claimed because native terminal capture was unavailable.

Real output excerpt:

```text
Before git commit -a -m:
 M tracked.txt
?? untracked.txt
After git commit -a -m (untracked.txt must remain):
?? untracked.txt
Selected feature commit: c7af93a308eff4958cc524ca395c72f6d026835d
selected cherry-pick content
PASS: commit -a and cherry-pick behaved as expected.
```

## Relevant files and learning summary

- [`git-practice-demo.sh`](git-practice-demo.sh) — disposable workflow; cleans only its own temp directory
- [`commit-a-vs-commit-m.md`](commit-a-vs-commit-m.md) — staging semantics and example
- [`cherry-pick.md`](cherry-pick.md) — hashes, conflicts, continue, and abort
- [`../evidence/command-outputs/git-practice-output.txt`](../evidence/command-outputs/git-practice-output.txt) — real generated output

The lesson is that the index is explicit state: `-a` is convenient for tracked edits but cannot discover new files, and cherry-pick transfers one change as a new commit rather than merging an entire branch.
