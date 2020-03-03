# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Disable dotnet collect information
export DOTNET_CLI_TELEMETRY_OPTOUT=1

#
# Prepend to PATH-like environment variables
#
function prepend_distinct() {
    # prepend_distinct <env_name> <values...>
    local env_name="$1"
    shift
    if [ -z "$env_name" ]; then
        echo "prepend_distinct env_name not given or empty"
        return 1
    fi

    local env_value="${!env_name}"

    for ((i=$#;i>0;i--)); do
        local value="${!i}"
        IFS=':' builtin read -r -a old_values <<< "$env_value"
        local found="no"
        for old_value in "${old_values[@]}"; do
            if [ "$old_value" = "$value" ]; then
                found="yes"
                break
            fi
        done
        if [ "$found" = "no" ]; then
            if [ -z "$env_value" ]; then
                env_value="$value"
            else
                env_value="$value:$env_value"
            fi
        fi
    done

    export "${env_name}=${env_value}"
}

function prepend_bin() {
    # prepend_bin <dirs...>
    prepend_distinct PATH "$@"
}

function prepend_lib() {
    # prepend_lib <dirs...>
    prepend_distinct LIBRARY_PATH "$@"
    prepend_distinct LD_LIBRARY_PATH "$@"
}

function prepend_inc() {
    # prepend_inc <dirs...>
    prepend_distinct CPATH "$@"
    prepend_distinct C_INCLUDE_PATH "$@"
    prepend_distinct CPLUS_INCLUDE_PATH "$@"
}

function prepend_install_root() {
    # prepend_install_root <dirs...>
    for dir in "$@"; do
        prepend_bin "${dir}/bin"
        prepend_lib "${dir}/lib64" "${dir}/lib"
        prepend_inc "${dir}/include"
    done
}


#
# Example:
#   prepend_install_root /opt/install /opt/more/install
#



# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if hash ip >&/dev/null; then
    my_netns="$(ip netns identify "$BASHPID")"
    if [ -n "$my_netns" ]; then
        my_netns="|$my_netns"
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1_PREF='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]'
    PS1_SUFF=':\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1="${PS1_PREF}${my_netns}${PS1_SUFF}"
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h${my_netns}:\w\$ '
fi
unset color_prompt force_color_prompt
unset my_netns

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -AhlF'
alias la='ls -AlF'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

