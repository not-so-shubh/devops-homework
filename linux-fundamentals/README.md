# Linux Fundamentals

This section covers filesystem links, account-creation tools, systemd logs, and a practical command reference. Run commands on Linux unless a note says otherwise.

## Soft (symbolic) link

A symbolic link is a small, separate filesystem object whose contents are a path to another file or directory. It has its own inode; it does **not** share the target's inode. The stored path can cross filesystem boundaries and may point to a directory. If the target pathname disappears, the symbolic link remains but becomes dangling.

```bash
ln -s target linkname
readlink linkname
```

Relative link targets are interpreted relative to the directory containing the link. This makes relative links portable when a directory tree moves as a unit.

## Hard link

A hard link adds another directory entry (another filename) for the same inode and file data. There is no privileged “original” name after creation. Because inode numbers are meaningful only inside one filesystem, a hard link normally cannot cross filesystem boundaries. Linux also normally prohibits users from hard-linking directories to protect the directory tree from cycles.

```bash
ln target linkname
```

Removing one name only decrements the inode's link count. The data remains accessible through other hard links until the final link is removed and no process still holds the file open.

## Interview-ready comparison

| Property | Symbolic link | Hard link |
|---|---|---|
| What it stores | A pathname to a target | Another directory entry for the same inode |
| Inode | Different from target | Same as every other hard-linked name |
| Cross filesystems | Yes | No |
| Link directories | Yes | Normally prohibited for ordinary users |
| Target name removed | Link becomes dangling | Remaining name still reads the data |
| Can point to a missing path | Yes | No; target must exist when created |
| Typical command | `ln -s target linkname` | `ln target linkname` |

An interview-quality short answer: “A symlink is its own inode containing a path, so it can cross filesystems and can dangle. A hard link is another filename for the same inode, so it stays valid when another filename is unlinked but cannot cross filesystems.”

## Inspection and deletion commands

```bash
ls -li original.txt soft-link hard-link  # show inode and link-count data
stat original.txt                         # detailed inode, link count, and timestamps
readlink soft-link                        # print a symbolic link's stored target
unlink soft-link                          # remove exactly one directory entry
rm hard-link                              # also unlinks the named entry
```

`rm` and `unlink` remove names; they do not “delete an inode” directly. Never use `rm -rf` for this exercise.

## Safe practice

The practice script creates a unique temporary directory, demonstrates both link types, removes the original filename, reports the expected dangling symlink, and removes its own temporary directory on exit.

```bash
chmod +x link-practice.sh
./link-practice.sh
```

See also:

- [adduser versus useradd](user-practice.md)
- [journalctl practice](journalctl-practice.md)
- [Linux command cheat sheet](linux-command-cheatsheet.md)
