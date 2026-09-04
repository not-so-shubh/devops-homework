# Cherry-Pick

`git cherry-pick <commit>` applies the change introduced by an existing commit to the current branch and, normally, creates a **new commit with a new hash**. It copies a change; it does not merge the entire source branch.

A commit hash is the object ID shown by commands such as `git log --oneline`. Use the real hash from your repository:

```bash
git switch main
git cherry-pick <SELECTED_COMMIT_HASH>
```

## Why use it?

- Bring one bug fix to a release branch without merging unrelated work.
- Recover a commit made on the wrong branch.
- Select a small, known change while keeping branch histories separate.

Cherry-picking many related commits can duplicate history and make later merges confusing; merging or rebasing may better express that intent.

## Conflicts

When Git cannot apply a change automatically:

```bash
git status
# edit files and resolve conflict markers
git add <resolved-files>
git cherry-pick --continue
```

To abandon the in-progress operation and restore the pre-cherry-pick state:

```bash
git cherry-pick --abort
```

Use `git log --oneline --graph --all --decorate` and inspect the resulting files to verify the selected change. The repository demo generates and prints a real selected hash at runtime; documentation intentionally does not invent one.
