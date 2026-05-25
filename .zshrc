#fastfetch

# P10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions web-search z)
source $ZSH/oh-my-zsh.sh

# Zoxide
eval "$(zoxide init zsh --cmd cd)"

# Tmux-Sessionizer
bindkey -s ^f "~/.tmux/plugins/tmux-sessionizer/tmux-sessionizer\n"

# Aliases
alias v="nvim"
alias ls="eza --icons=auto"
alias ll="eza -a --icons=auto -l --group-directories-first"
alias lg="lazygit"
alias zshconfig="nvim ~/.zshrc"
alias cc="claude"

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
