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

## Dependencies bootstrap does NOT install

`bootstrap.sh` stows configuration; it does not provision applications. Most
of them (hyprland, wezterm, neovim, rofi, mako…) come from the distro and are
assumed present. Three exceptions are not, and the desktop fails in confusing
ways without them.

**quickshell** — the bar, notifications OSD and desktop widgets. Not in the
Ubuntu repos. `hyprland.conf` runs `exec-once = qs`, so without it you boot to
a desktop with no bar:

```sh
sudo add-apt-repository -y ppa:avengemedia/danklinux
sudo apt update && sudo apt install quickshell
```

Note quickshell links private Qt APIs and its dependencies pin the Qt version
exactly (`qt6-base-private-abi (= 6.10.2)` at time of writing). A Qt point
release will hold it back until the PPA rebuilds. That is inherent to
quickshell, not to this PPA.

**qml6-module-qtquick-effects** — a *hard* requirement, not an enhancement.
`MultiEffect` draws the album-art blur and every text shadow on the desktop
widgets, and QML import failures are fatal: without this the shell does not
start at all.

```sh
sudo apt install qml6-module-qtquick-effects
```

**Maple Mono NF CN** — the shell's typeface, set in
`quickshell/.config/quickshell/Theme.qml`. Not in any repo; the apt font
packages are unpatched builds with no Nerd Font glyphs. The CN build matters
specifically: it carries latin, the Nerd Font icons *and* Chinese in one face,
so the workspace numerals 一二三四五 do not fall back to a different typeface.

```sh
curl -LO https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-NF-CN.zip
mkdir -p ~/.local/share/fonts/MapleMono
unzip -o MapleMono-NF-CN.zip -d ~/.local/share/fonts/MapleMono
fc-cache -f
```

Without it the shell still runs, but every glyph falls back and the bar looks
nothing like it should.

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
