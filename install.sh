#!/usr/bin/env bash
# Symlink the dotfiles into place, backing up any existing file first. Idempotent.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.box-dots-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src=$1 dst=$2
  if [[ -L $dst && "$(readlink -- "$dst")" == "$src" ]]; then
    echo "ok     $dst"
    return
  fi
  if [[ -e $dst || -L $dst ]]; then
    mkdir -p "$BACKUP_DIR"
    mv -- "$dst" "$BACKUP_DIR/"
    echo "backup $dst -> $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname -- "$dst")"
  ln -s -- "$src" "$dst"
  echo "link   $dst"
}

link "$REPO_DIR/dotfiles/bashrc"    "$HOME/.bashrc"
link "$REPO_DIR/dotfiles/tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/dotfiles/vimrc"     "$HOME/.vimrc"

for f in "$REPO_DIR"/bin/*; do
  chmod +x "$f"
  link "$f" "$HOME/.local/bin/$(basename "$f")"
done

mkdir -p "$HOME/.vim/undo"

echo "Done. Open a new shell or run: source ~/.bashrc"
