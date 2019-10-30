# A modern, informative and configurable command prompt for the Bash shell.
#
# URL:     github.com/bluz71/bash-seafly-prompt
# License: MIT (https://opensource.org/licenses/MIT)


_interactive_terminal=0
if [[ "$-" =~ i ]]; then
    _interactive_terminal=1
fi

_color_terminal=0
if [[ $TERM = "xterm-256color" || $TERM = "screen-256color" ]]; then
    _color_terminal=1
fi

# Colors used in the prompt.
if [[ $_interactive_terminal = 1 && $_color_terminal = 1 ]]; then
    if [[ -z $SEAFLY_PREFIX_COLOR ]]; then
        SEAFLY_PREFIX_COLOR=$(tput setaf 153)
    fi
    if [[ -z $SEAFLY_NORMAL_COLOR ]]; then
        SEAFLY_NORMAL_COLOR=$(tput setaf 111)
    fi
    if [[ -z $SEAFLY_ALERT_COLOR ]]; then
        SEAFLY_ALERT_COLOR=$(tput setaf 203)
    fi
    if [[ -z $SEAFLY_HOST_COLOR ]]; then
        SEAFLY_HOST_COLOR=$(tput setaf 255)
    fi
    if [[ -z $SEAFLY_GIT_COLOR ]]; then
        SEAFLY_GIT_COLOR=$(tput setaf 147)
    fi
    if [[ -z $SEAFLY_PATH_COLOR ]]; then
        SEAFLY_PATH_COLOR=$(tput setaf 150)
    fi
    NOCOLOR=$(tput sgr0)
fi

# Shorten directory paths to a maximum of four components unless PROMPT_DIRTRIM
# has already been set.
if [[ -z $PROMPT_DIRTRIM ]]; then
    PROMPT_DIRTRIM=4
fi

if [[ -z $SEAFLY_SHOW_USER ]]; then
    SEAFLY_SHOW_USER=0
fi

if [[ -z $SEAFLY_LAYOUT ]]; then
    SEAFLY_LAYOUT=1
fi

# Symbols used in the prompt.
if [[ -z $SEAFLY_PROMPT_SYMBOL ]]; then
    SEAFLY_PROMPT_SYMBOL="❯"
fi
if [[ -z $SEAFLY_PS2_PROMPT_SYMBOL ]]; then
    SEAFLY_PS2_PROMPT_SYMBOL="❯"
fi
if [[ -z $SEAFLY_GIT_PREFIX ]]; then
    SEAFLY_GIT_PREFIX=""
fi
if [[ -z $SEAFLY_GIT_SUFFIX ]]; then
    SEAFLY_GIT_SUFFIX=""
fi
if [[ -z $SEAFLY_GIT_DIRTY ]]; then
    SEAFLY_GIT_DIRTY="✗"
fi
if [[ -z $SEAFLY_GIT_STAGED ]]; then
    SEAFLY_GIT_STAGED="✓"
fi
if [[ -z $SEAFLY_GIT_STASH ]]; then
    SEAFLY_GIT_STASH="⚑"
fi
if [[ -z $SEAFLY_GIT_AHEAD ]]; then
    SEAFLY_GIT_AHEAD="↑"
fi
if [[ -z $SEAFLY_GIT_BEHIND ]]; then
    SEAFLY_GIT_BEHIND="↓"
fi
if [[ -z $SEAFLY_GIT_DIVERGED ]]; then
    SEAFLY_GIT_DIVERGED="↕"
fi

# Collate Git details using just the 'git' command.
#
_git_details_fallback() {
    if [[ $(git rev-parse --is-inside-work-tree --is-bare-repository 2>/dev/null) =~ true ]]; then
        local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
        if [[ $branch = "HEAD" ]]; then
            branch="detached*$(git rev-parse --short HEAD 2>/dev/null)"
        fi

        local dirty
        local staged
        if [[ $branch != "detached*" &&
              $GIT_PS1_SHOWDIRTYSTATE != 0 &&
              $(git config --bool bash.showDirtyState) != "false" ]]; then
            git diff --no-ext-diff --quiet --exit-code --ignore-submodules 2>/dev/null || dirty=$SEAFLY_GIT_DIRTY
            git diff --no-ext-diff --quiet --cached --exit-code --ignore-submodules 2>/dev/null || staged=$SEAFLY_GIT_STAGED
        fi

        local stash
        if [[ $GIT_PS1_SHOWSTASHSTATE != 0 ]]; then
            git rev-parse --verify --quiet refs/stash >/dev/null && stash=$SEAFLY_GIT_STASH
        fi

        local upstream
        if [[ $GIT_PS1_SHOWUPSTREAM != 0 ]]; then
            case "$(git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)" in
            "") # no upstream
                upstream="" ;;
            "0	0") # equal to upstream
                upstream="=" ;;
            "0	"*) # behind upstream
                upstream=$SEAFLY_GIT_BEHIND ;;
            *"	0") # ahead of upstream
                upstream=$SEAFLY_GIT_AHEAD ;;
            *)	    # diverged from upstream
                upstream=$SEAFLY_GIT_DIVERGED ;;
            esac
        fi

        local spacer
        if [[ -n $dirty || -n $staged || -n $stash || -n $upstream ]]; then
            spacer=" "
        fi
        export SEAFLY_GIT_DETAILS=" $SEAFLY_GIT_PREFIX$branch$spacer\[$SEAFLY_ALERT_COLOR\]$dirty\[$SEAFLY_NORMAL_COLOR\]$staged$upstream\[$SEAFLY_GIT_COLOR\]$stash$SEAFLY_GIT_SUFFIX"
    fi
}

# Collate Git details using the optimized
# [gitstatus](https://github.com/romkatv/gitstatus) command.
#
_git_details_optimized() {
    if gitstatus_query && [[ $VCS_STATUS_RESULT == ok-sync ]]; then
        local branch=$VCS_STATUS_LOCAL_BRANCH
        if [[ -z $branch ]]; then
            branch="detached*$(git rev-parse --short HEAD 2>/dev/null)"
        fi

        local dirty
        local staged
        if [[ $GIT_PS1_SHOWDIRTYSTATE != 0 &&
              $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
            dirty=$SEAFLY_GIT_DIRTY
        fi
        if [[ $GIT_PS1_SHOWDIRTYSTATE != 0 &&
              $VCS_STATUS_HAS_STAGED == 1 ]]; then
            staged=$SEAFLY_GIT_STAGED
        fi

        local stash
        if [[ $GIT_PS1_SHOWSTASHSTATE != 0 && $VCS_STATUS_STASHES -gt 0 ]]; then
            stash=$SEAFLY_GIT_STASH
        fi

        local upstream
        if [[ $GIT_PS1_SHOWUPSTREAM != 0 ]]; then
            if [[ $VCS_STATUS_COMMITS_AHEAD -gt 0 &&
                  $VCS_STATUS_COMMITS_BEHIND -gt 0 ]]; then
                upstream=$SEAFLY_GIT_DIVERGED
            elif [[ $VCS_STATUS_COMMITS_AHEAD -gt 0 ]]; then
                upstream=$SEAFLY_GIT_AHEAD
            elif [[ $VCS_STATUS_COMMITS_BEHIND -gt 0 ]]; then
                upstream=$SEAFLY_GIT_BEHIND
            fi
        fi

        local spacer
        if [[ -n $dirty || -n $staged || -n $stash || -n $upstream ]]; then
            spacer=" "
        fi
        export SEAFLY_GIT_DETAILS=" $SEAFLY_GIT_PREFIX$branch$spacer\[$SEAFLY_ALERT_COLOR\]$dirty\[$SEAFLY_NORMAL_COLOR\]$staged$upstream\[$SEAFLY_GIT_COLOR\]$stash$SEAFLY_GIT_SUFFIX"
    fi
}

_command_prompt() {
    # Run a pre-command if set.
    if [[ -n $SEAFLY_PRE_COMMAND ]]; then
        eval $SEAFLY_PRE_COMMAND
    fi

    # Set a simple prompt for non-interactive or non-color terminals.
    if [[ $_interactive_terminal = 0 || $_color_terminal = 0 ]]; then
        PS1='\h \w > '
        return
    fi

    local prompt_prefix
    if [[ -n $SEAFLY_PROMPT_PREFIX ]]; then
        local prefix_value=$(eval $SEAFLY_PROMPT_PREFIX)
        if [[ -n $prefix_value ]]; then
            prompt_prefix="\[$SEAFLY_PREFIX_COLOR\]$prefix_value "
        fi
    fi

    local prompt_start
    if [[ $SEAFLY_SHOW_USER = 1 ]]; then
        prompt_start="\[$SEAFLY_HOST_COLOR\]\u@\h"
    else
        prompt_start="\[$SEAFLY_HOST_COLOR\]\h"
    fi

    # Collate Git details, if applicable, for the current directory.
    if [[ -z $GITSTATUS_DIR ]]; then
        _git_details_fallback
    else
        _git_details_optimized
    fi

    local prompt_middle
    if [[ $SEAFLY_LAYOUT = 1 ]]; then
        prompt_middle="\[$SEAFLY_GIT_COLOR\]$SEAFLY_GIT_DETAILS\[$SEAFLY_PATH_COLOR\] \w"
    else
        prompt_middle="\[$SEAFLY_PATH_COLOR\] \w\[$SEAFLY_GIT_COLOR\]$SEAFLY_GIT_DETAILS"
    fi
    unset SEAFLY_GIT_DETAILS

    # Normal prompt indicates that the last command ran successfully.
    # Alert prompt indicates that the last command failed.
    local prompt_end="\$(if [[ \$? = 0 ]]; then echo \[\$SEAFLY_NORMAL_COLOR\]; else echo \[\$SEAFLY_ALERT_COLOR\]; fi) $SEAFLY_PROMPT_SYMBOL\[\$NOCOLOR\] "

    PS1="$prompt_prefix$prompt_start$prompt_middle$prompt_end"
    PS2="\[$SEAFLY_NORMAL_COLOR\]$SEAFLY_PS2_PROMPT_SYMBOL\[\$NOCOLOR\] "
}

# Use [gitstatus](https://github.com/romkatv/gitstatus) if it is available.
if [[ -d ~/.gitstatus ]]; then
    export GITSTATUS_DIR=~/.gitstatus
fi
if [[ -f $GITSTATUS_DIR/gitstatus.prompt.sh ]]; then
    source ~/.gitstatus/gitstatus.prompt.sh
    gitstatus_stop && gitstatus_start
fi

# Bind the '_command_prompt' function as the Bash prompt.
PROMPT_COMMAND=_command_prompt
