SSH in, feel at home. My config on any Linux box I land on.

```bash
git clone https://github.com/rh33t/box-dots && cd box-dots && ./install.sh
```

Backs up what it replaces into `~/.box-dots-backup/<date>/`. `git pull` to update.

## TERM / terminfo (optional)

No `$TERM` forced. tmux expects `tmux-256color`, and the client's `$TERM`
(e.g. `foot`) must exist on the box. Only if a tool complains with `missing or
unsuitable terminal`, push the local terminfo over:

```bash
infocmp -x "$TERM" | ssh host -- tic -x -
```

Needs `tic` on the remote (`ncurses-bin`). Last resort: `TERM=xterm-256color ssh host`.
