# `git commit -m` versus `git commit -a -m`

```bash
git commit -m "message"
```

This commits exactly what is already in the index (staging area). Use `git add <path>` first to choose new files and/or changes.

```bash
git commit -a -m "message"
```

`-a` tells Git to stage modifications and deletions of files Git **already tracks**, then commit the resulting index. It does **not** stage brand-new untracked files. This limitation is useful: an unexpected new file is not silently included, but it also means `-a` is not a replacement for `git add`.

## Minimal example

```bash
echo update >> tracked.txt
echo new > untracked.txt
git status --short
#  M tracked.txt
# ?? untracked.txt

git commit -a -m "Update tracked file"
git status --short
# ?? untracked.txt
```

The commented output is illustrative, not captured evidence. Run `git-practice-demo.sh` for genuine output generated from a temporary repository.

`git status` and `git diff --cached` should be reviewed before committing. For precise commits, explicit `git add <paths>` is often clearer than `-a`.
