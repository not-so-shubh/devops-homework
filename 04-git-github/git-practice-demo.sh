#!/usr/bin/env bash
set -euo pipefail

DEMO_DIR="$(mktemp -d "${TMPDIR:-/tmp}/devops-git-practice.XXXXXX")"

cleanup() {
  rm -rf -- "$DEMO_DIR"
}
trap cleanup EXIT

cd "$DEMO_DIR"
git init -b main
git config user.name "DevOps Practice"
git config user.email "devops-practice@example.invalid"

echo "Temporary repository: $DEMO_DIR"

printf '# Disposable Git Practice\n' > README.md
git add README.md
git commit -m "Initialize practice repository"

printf 'tracked line 1\n' > tracked.txt
git add tracked.txt
git commit -m "Add tracked demonstration file"

printf 'main branch notes\n' > main-notes.txt
git add main-notes.txt
git commit -m "Document main branch workflow"

echo
echo "=== commit -a demonstration ==="
printf 'tracked line 2\n' >> tracked.txt
printf 'brand-new untracked content\n' > untracked.txt
echo "Before git commit -a -m:"
git status --short
git commit -a -m "Update already tracked file"
echo "After git commit -a -m (untracked.txt must remain):"
git status --short

if ! git status --short | grep -q '^?? untracked.txt$'; then
  echo "FAIL: the expected untracked file was not present." >&2
  exit 1
fi

git switch -c feature-demo
printf 'independent feature one\n' > feature-one.txt
git add feature-one.txt
git commit -m "Add first feature"

printf 'selected cherry-pick content\n' > selected-feature.txt
git add selected-feature.txt
git commit -m "Add selected feature"
SELECTED_COMMIT="$(git rev-parse HEAD)"

echo
echo "Selected feature commit: $SELECTED_COMMIT"
git switch main
git cherry-pick "$SELECTED_COMMIT"

echo
echo "=== Graph after cherry-pick ==="
git log --oneline --graph --all --decorate

echo
echo "=== Verify selected content ==="
grep -F "selected cherry-pick content" selected-feature.txt

echo
echo "=== Final status (the untracked demo file intentionally remains) ==="
git status --short --branch

test -f selected-feature.txt
grep -Fq "selected cherry-pick content" selected-feature.txt
echo "PASS: commit -a and cherry-pick behaved as expected."
