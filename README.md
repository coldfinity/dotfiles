# dotfiles

My macOS config, managed with [GNU stow](https://www.gnu.org/software/stow/).

## How it's organised

The repo is laid out like a normal Mac home folder. Files live where they
live in `~`: `.zshrc` at the top level, `.config/nvim` for Neovim, and so on.
There are no per-app wrapper folders. Stow treats the whole repo as one package
and symlinks it into `$HOME`, and `.stow-local-ignore` keeps repo-only files
(`README.md`, `.git`, `docs`, …) out of it.

```
.zshrc  .tmux.conf  .wezterm.lua
.config/{aerospace,fastfetch,ghostty,herdr,nvim,sketchybar,starship.toml,tmux-sessionizer}
.local/bin/{how,gclone}
```

The repo lives at `~/Documents/projects/dotfiles`.

This is macOS-only. I dropped the Linux setup (Hyprland, Waybar, Quickshell,
Rofi, Mako, fcitx5), and it only survives in git history. I also dropped typst
and the bootstrap script, because stow plus a couple of commands is all this
needs.

## Setup

```sh
brew install stow
git clone <this-repo> ~/Documents/projects/dotfiles
mkdir -p ~/.config/herdr          # required, see the warning below
cd ~/Documents/projects/dotfiles
stow -d .. dotfiles               # run from inside the repo
```

`.stowrc` sets the target to `$HOME`. `-d ..` makes the repo's parent the stow
directory, so `dotfiles` is the package name (use the folder's name if you
rename it).

If stow reports a conflict, a real file already exists at that path in `$HOME`.
Back it up (`mv ~/.zshrc ~/.zshrc.bak`) and re-stow.

## Everyday use

```sh
stow -d .. -R dotfiles    # restow after adding files
stow -d .. -D dotfiles    # unstow everything
```

If you move this folder, unstow first, move it, then restow. The links in
`$HOME` are relative and break otherwise.

## ⚠️ herdr: create `~/.config/herdr` before stowing

herdr keeps runtime state (sockets, logs, `session*.json`) in `~/.config/herdr`,
and only `config.toml` is tracked. If that folder doesn't exist when you run
stow, stow links the **whole folder** to the repo, and herdr's runtime files
end up inside the repo. Always run `mkdir -p ~/.config/herdr` first, so stow
links only `config.toml`.

## Notes and work in progress

- **Neovim treesitter** is being redone. Parsers and queries are generated
  per-machine by nvim-treesitter, so `.config/nvim/queries/` is gitignored and
  not tracked.
- **Prompt:** [starship](https://starship.rs) with a minimal config in
  `.config/starship.toml` (directory, git, prompt character). Install it with
  `brew install starship`; `.zshrc` loads it.
- Third-party clones in my home folder (`vim`, `iterm`, `spicetify-themes`)
  are deliberately not part of this repo.
