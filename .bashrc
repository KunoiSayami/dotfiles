# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# /etc/bash.bashrc
#
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output. So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell. There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

# If not running interactively, don't do anything!
[[ $- != *i* ]] && return

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.
shopt -s histappend

# source: https://thucnc.medium.com/how-to-show-current-git-branch-with-colors-in-bash-prompt-380d05a24745
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

get_last_status() {
    _LAST_STATUS=$?
    [[ $_LAST_STATUS != 0 ]] && echo " $_LAST_STATUS :("
    unset _LAST_STATUS
}

parse_git_commit_diff() {
    _CURRENT_BRANCH=$(parse_git_branch)
    if [ -z $_CURRENT_BRANCH ]; then
        unset _CURRENT_BRANCH
        return
    fi
    # https://stackoverflow.com/a/27940027
    # https://stackoverflow.com/a/13402368
    _BRANCH_COMMIT_DIFF=($(git rev-list --left-right --count $_CURRENT_BRANCH...origin/$_CURRENT_BRANCH))

    if [[ ${_BRANCH_COMMIT_DIFF[0]} != "0" ]]; then
        _AHEAD="↑${_BRANCH_COMMIT_DIFF[0]}"
    fi
    if [[ ${_BRANCH_COMMIT_DIFF[1]} != "0" ]]; then
        _BEHIND="↓${_BRANCH_COMMIT_DIFF[1]}"
    fi
    if [ ! -z ${_AHEAD+x} ] || [ ! -z ${_BEHIND+x} ]; then
        _SPLIT="\033[0;m:"
    fi
    # https://stackoverflow.com/a/5947802
    echo -e " <$_CURRENT_BRANCH$_SPLIT\033[0;32m$_AHEAD$_BEHIND\033[0;31m>";
    unset _CURRENT_BRANCH
    unset _BRANCH_COMMIT_DIFF
    unset _BEHIND
    unset _AHEAD
    unset _SPLIT
}

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=10000

case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
    screen)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
esac


# https://askubuntu.com/a/67306
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# fortune is a simple program that displays a pseudorandom message
# from a database of quotations at logon and/or logout.
# If you wish to use it, please install "fortune-mod" from the
# official repositories, then uncomment the following line:

#[[ "$PS1" ]] && /usr/bin/fortune

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS. Try to use the external file
# first to take advantage of user additions. Use internal bash
# globbing instead of external grep binary.

# sanitize TERM:
safe_term=${TERM//[^[:alnum:]]/?}
match_lhs=""

[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)

if [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] || [ $TERM == "xterm-256color" ]; then

    # we have colors :-)

    # Enable colors for ls, etc. Prefer ~/.dir_colors
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    PS1="$( echo '\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]')\[\033[01;34m\]\w\[\033[01;31m\]\$(get_last_status)\[\033[01;00m\]\[\e[91m\]\$(parse_git_commit_diff)\[\e[00m\] \\$\[\033[00m\] "

    # Use this other PS1 string if you want \W for root and \w for all other users:
    # PS1="$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]\h\[\033[01;34m\] \W'; else echo '\[\033[01;32m\]\u@\h\[\033[01;34m\] \w'; fi) \$([[ \$? != 0 ]] && echo \"\[\033[01;31m\]:(\[\033[01;34m\] \")\\$\[\033[00m\] "

    alias ls="ls --color=auto"
    alias dir="dir --color=auto"
    alias grep="grep --color=auto"
    alias dmesg='dmesg --color'

    # Uncomment the "Color" line in /etc/pacman.conf instead of uncommenting the following line...!

    # alias pacman="pacman --color=auto"

    # show root@ when we do not have colors
else
    PS1="\u@\h \w \$([[ \$? != 0 ]] && echo \":( \") \$(parse_git_branch) \$ "

    # Use this other PS1 string if you want \W for root and \w for all other users:
    # PS1="\u@\h $(if [[ ${EUID} == 0 ]]; then echo '\W'; else echo '\w'; fi) \$([[ \$? != 0 ]] && echo \":( \")\$ "
fi

PS2="> "
PS3="> "
PS4="+ "

# Try to keep environment pollution down, EPA loves us :-)
unset safe_term match_lhs

# Try to enable the auto-completion (type: "pacman -S bash-completion" to install it).
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Try to enable the "Command not found" hook ("pacman -S pkgfile" to install it).
# See also: https://wiki.archlinux.org/index.php/Bash#The_.22command_not_found.22_hook
# [ -r /usr/share/doc/pkgfile/command-not-found.bash ] && . /usr/share/doc/pkgfile/command-not-found.bash

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'
export PATH=$PATH:~/.local/bin

# rust rated
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUST_LOG=debug
[ -r ~/.cargo/env ] && source "$HOME/.cargo/env"
export DISK_WAIT_TIME=500


export GPG_TTY=$(tty)

# Option for enable ssh agent, uncomment it to enable
#ENABLE_SSH_AGENT="true"

enable_gpg_agent() {
    unset SSH_AGENT_PID
    SOCK_TARGET=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --create-socketdir
    if [[ $SOCK_TARGET != $SSH_AUTH_SOCK ]]; then
        export SSH_AUTH_SOCK=$SOCK_TARGET
        echo "Use gpg agent to provide authentication service"
    fi

    _GPG_MATCH=$(ps -x | grep gpg-agent | grep -v grep)

    if [ ! -z ${_GPG_MATCH+x} ]; then
        gpgconf --launch gpg-agent
    fi
    unset _GPG_MATCH
}

enable_ssh_agent() {
    if [ -z ${SSH_AGENT_PID+x} ]; then
        SSH_AGENT_FILE=/run/user/$(id -u)/ssh-agent.$(whoami)
        if [ ! -f $SSH_AGENT_FILE  ]; then
            touch $SSH_AGENT_FILE
            chmod 600 $SSH_AGENT_FILE
            ssh-agent > $SSH_AGENT_FILE
        fi
        eval $(cat $SSH_AGENT_FILE)
    fi
}

export -f enable_ssh_agent
export -f enable_gpg_agent

# To disable all agent, uncomment next line
DISABLE_AGENTS=""

if [ -z ${DISABLE_AGENTS+x} ]; then
    if [ ! -z $ENABLE_SSH_AGENT ] && [ $ENABLE_SSH_AGENT == "true" ]; then
        enable_ssh_agent
    else
        enable_gpg_agent
    fi
fi


[ -r ~/.config/shadowsocks/env ] && . ~/.config/shadowsocks/env

true
