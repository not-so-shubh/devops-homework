#!/usr/bin/env bash
set -euo pipefail

PRACTICE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/devops-link-practice.XXXXXX")"

cleanup() {
  # PRACTICE_DIR is created by mktemp above and is never supplied by the caller.
  rm -rf -- "$PRACTICE_DIR"
}
trap cleanup EXIT

ORIGINAL="$PRACTICE_DIR/original.txt"
SOFT_LINK="$PRACTICE_DIR/soft-link.txt"
HARD_LINK="$PRACTICE_DIR/hard-link.txt"

printf 'Practice directory: %s\n' "$PRACTICE_DIR"
printf 'Hello through a Linux inode.\n' > "$ORIGINAL"
ln -s "original.txt" "$SOFT_LINK"
ln "$ORIGINAL" "$HARD_LINK"

printf '\n1. All three names (the hard link shares the original inode):\n'
ls -li "$ORIGINAL" "$SOFT_LINK" "$HARD_LINK"

printf '\n2. Detailed original-file metadata:\n'
stat "$ORIGINAL"

printf '\n3. Symbolic link stores this target path:\n'
readlink "$SOFT_LINK"

printf '\n4. Read through each link:\n'
printf 'soft: '
cat "$SOFT_LINK"
printf 'hard: '
cat "$HARD_LINK"

printf '\n5. Remove only the original filename with unlink:\n'
unlink "$ORIGINAL"
ls -li "$SOFT_LINK" "$HARD_LINK"

printf '\n6. Hard link still reads the inode data:\n'
cat "$HARD_LINK"

printf '\n7. Symbolic link is now dangling:\n'
if cat "$SOFT_LINK" 2>/dev/null; then
  printf 'UNEXPECTED: dangling symbolic link was readable.\n' >&2
  exit 1
else
  printf 'EXPECTED: reading the symbolic link failed because original.txt is gone.\n'
fi

rm "$SOFT_LINK" "$HARD_LINK"
printf '\nPASS: link behavior matched expectations; cleanup will remove the temporary directory.\n'
