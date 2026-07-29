# dotfiles

Personal config, managed with [GNU stow](https://www.gnu.org/software/stow/).
Each top-level directory is a stow **package** whose contents mirror `$HOME`
(e.g. `nvim/.config/nvim/…` → `~/.config/nvim/…`). A `.stowrc` pins the target
to `$HOME`, so stow is always run from inside this repo.

## New machine

```sh
git clone <this-repo> ~/projects/dotfiles
cd ~/projects/dotfiles
./bootstrap.sh
```

`bootstrap.sh` detects Linux vs macOS and:

- installs `stow`, a C compiler, and the `tree-sitter` CLI (into `~/.local/bin`)
- stows the packages for this OS (macOS also gets `aerospace` + `sketchybar`)
- links the typst package into the right data dir (`~/.local/share/typst` on
  Linux, `~/Library/Application Support/typst` on macOS)
- compiles the Neovim treesitter parsers

It's idempotent — safe to re-run.

## Manual use

```sh
cd ~/projects/dotfiles
stow */          # stow every package
stow nvim ghostty  # or specific ones
stow -D nvim     # unstow a package
stow -R nvim     # restow (after adding files)
```

If stow reports a conflict, a real file already exists at that path in `$HOME`;
back it up (`mv ~/.zshrc ~/.zshrc.bak`) and re-stow.

## Notes

- **Treesitter parsers** are compiled per-machine into `~/.local/share/nvim/`
  and are not tracked here; only the query files (`nvim/.config/nvim/queries/`)
  live in git. `bootstrap.sh` (or opening nvim) builds the parsers.
- **typst** is a local package (`@local/notes`). Its data-dir path differs by
  OS — see `bootstrap.sh`; don't `stow typst` on macOS.
- **herdr** shares `~/.config/herdr` with runtime state (sockets, logs,
  `session*.json`), so only `config.toml` is tracked and the package is stowed
  with `--no-folding` — plain `stow herdr` on a fresh machine would symlink the
  whole directory and pull that state into the repo.
