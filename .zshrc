# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Autosuggestion colour. The plugin default (fg=8) is nearly invisible in
# this terminal theme; 244 is a fixed mid-grey that stays readable.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

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

# pnpm
export PNPM_HOME="/Users/yudiwu/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# PATH
# covers pipx-installed tools and stowed scripts (gclone, how)
export PATH="$HOME/.local/bin:$PATH"

# Zoxide (keep last — it wraps `cd`)
eval "$(zoxide init zsh --cmd cd)"

# starship theme
eval "$(starship init zsh)"
