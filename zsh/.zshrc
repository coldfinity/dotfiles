# printf '\n  \033[1m  Commands\033[0m\n'
# printf '  %-12s %s\n' \
#   'v'         'nvim' \
#   'lg'        'lazygit' \
#   'claude'    'claude code' \
#   'opencode'  'opencode' \
#   'z'         'jump dir (zoxide)' \
#   'mole'      'ssh tunnel' \
#   'btop'      'system monitor' \
#   'C-f'       'tmux sessionizer' \
#   'll'        'ls -la with icons' \
#   'zshconfig' 'edit this file' \
#   'gclone'    'git clone script'
# echo

#fastfetch

# P10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="robbyrussell"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions web-search z)
source $ZSH/oh-my-zsh.sh

# Tmux-Sessionizer
bindkey -s ^f "~/.tmux/plugins/tmux-sessionizer/tmux-sessionizer\n"

# Aliases
alias v="nvim"
alias ls="eza --icons=auto"
alias ll="eza -a --icons=auto -l --group-directories-first"
alias lg="lazygit"
alias zshconfig="nvim ~/.zshrc"
alias Preview="open -a Preview"

# History setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# P10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/Users/yudiwu/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# PATH
export PATH="/opt/nvim/bin:$PATH"
# also covers pipx-installed tools and stowed scripts (gclone, how)
export PATH="$HOME/.local/bin:$PATH"

# Both of these were appended by their own installers, with /home/yudi-wu
# hardcoded. This file is stowed on macOS too, where neither directory
# exists, so they are rewritten to use $HOME and guarded — an absent
# directory would otherwise sit on PATH doing nothing.
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"
# spicetify: needed to re-run `spicetify backup apply`, since a Spotify
# update through apt replaces the patched files with stock ones.
[ -d "$HOME/.spicetify" ] && export PATH="$PATH:$HOME/.spicetify"

# Zoxide (keep last — it wraps `cd`)
eval "$(zoxide init zsh --cmd cd)"
