#!/usr/bin/env bash
# Symlink the dotfiles into place, backing up any existing file first. Idempotent.

set -euo pipefail
umask 077

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_ROOT="$HOME/.box-dots-backup"
BACKUP_DIR=''

fail() {
  echo "Error: $*" >&2
  exit 1
}

[[ -d $HOME && -O $HOME && -w $HOME ]] || fail "HOME must be an owned, writable directory: $HOME"

shopt -s nullglob
BIN_FILES=("$REPO_DIR"/bin/*)
[[ ${#BIN_FILES[@]} -gt 0 ]] || fail "No scripts found in $REPO_DIR/bin"

for src in "$REPO_DIR"/dotfiles/{bashrc,tmux.conf,vimrc} "${BIN_FILES[@]}"; do
  [[ -f $src && -r $src ]] || fail "Source must be a readable file: $src"
done

for dir in "$BACKUP_ROOT" "$HOME/.local" "$HOME/.local/bin" "$HOME/.vim" "$HOME/.vim/undo"; do
  [[ ! -L $dir ]] || fail "Refusing symlinked directory: $dir"
  if [[ -e $dir ]]; then
    [[ -d $dir && -O $dir && -w $dir ]] || fail "Directory must be owned and writable: $dir"
  fi
done

mkdir -p -- "$HOME/.local/bin" "$HOME/.vim/undo"
chmod 700 -- "$HOME/.vim/undo"

link() {
  local src=$1 dst=$2
  local backup=''
  if [[ -L $dst && "$(readlink -- "$dst")" == "$src" ]]; then
    echo "ok     $dst"
    return
  fi
  if [[ -e $dst || -L $dst ]]; then
    if [[ -z $BACKUP_DIR ]]; then
      mkdir -p -- "$BACKUP_ROOT"
      chmod 700 -- "$BACKUP_ROOT"
      BACKUP_DIR=$(mktemp -d "$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S).XXXXXX")
    fi
    backup="$BACKUP_DIR/${dst#"$HOME/"}"
    mkdir -p -- "$(dirname -- "$backup")"
    mv -T -- "$dst" "$backup"
    echo "backup $dst -> $backup"
  fi
  if ! ln -sT -- "$src" "$dst"; then
    if [[ -n $backup ]]; then
      mv -T -- "$backup" "$dst"
    fi
    return 1
  fi
  echo "link   $dst"
}

link "$REPO_DIR/dotfiles/bashrc"    "$HOME/.bashrc"
link "$REPO_DIR/dotfiles/tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/dotfiles/vimrc"     "$HOME/.vimrc"

for f in "${BIN_FILES[@]}"; do
  chmod u+x -- "$f"
  link "$f" "$HOME/.local/bin/$(basename "$f")"
done

echo "Done. Open a new shell or run: source ~/.bashrc"
