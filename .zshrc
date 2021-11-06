# Lines configured by zsh-newuser-install
setopt beep
# End of lines configured by zsh-newuser-install
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# inputrc
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# colors
autoload -U colors && colors
#[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [ -r /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]; then
    [ -r ~/.config/zsh/p10k.zsh ] && source ~/.config/zsh/p10k.zsh
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
else
    autoload -Uz vcs_info
    precmd_vcs_info() { vcs_info }
    precmd_functions+=( precmd_vcs_info )
    setopt prompt_subst
    RPROMPT=\$vcs_info_msg_0_
    zstyle ':vcs_info:git:*' formats '%F{9}(%b)%m%f '
    zstyle ':vcs_info:git*+set-message:*' hooks git-st
    zstyle ':vcs_info:*' enable git

    PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[green]%}%m%{$reset_color%}:%{$fg[yellow]%}%~ %{$fg[red]%}%(?..%? :(%{$reset_color%} )%{$reset_color%}%# \$vcs_info_msg_0_"
fi

# some alias
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# set completions
autoload -Uz compinit promptinit
compinit
promptinit
zstyle ':completion:*' menu select
[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#prompt walters
which pip >/dev/null && eval "`pip completion --zsh`"


IS_MAINLAND=false

if [ IS_MAINLAND ]; then
	export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
	export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
fi

export GPG_TTY=$(tty)
#eval $(starship init zsh)

alias pau="sudo pacman -Syu"
alias pai="sudo pacman -S"
alias paiy="sudo pacman -Sy"
alias pas="pacman -Ss"
alias paq="pacman -Qs"
alias pasi="pacman -Si"
alias paf="pacman -F"
alias pafy="sudo pacman -Fy"

alias gowin="sudo bootctl set-oneshot auto-windows"
