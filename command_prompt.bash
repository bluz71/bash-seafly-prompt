# A modern, informative and configurable command prompt for the Bash shell.
#
# URL:     github.com/bluz71/bash-seafly-prompt
# License: MIT (https://opensource.org/licenses/MIT)


# Non-interactive shells don't have a prompt, exit early.
[[ $- =~ i ]] || return 0

# Set a simple prompt for non-256color and non-kitty terminals.
if [[ $TERM != *-256color ]] && [[ $TERM != *-kitty ]]; then
    PS1='\h \w > '
    return 0
fi

# Default colors used in the prompt.
: ${SEAFLY_PREFIX_COLOR:=$(tput setaf 153)}
: ${SEAFLY_NORMAL_COLOR:=$(tput setaf 111)}
: ${SEAFLY_ALERT_COLOR:=$(tput setaf 203)}
: ${SEAFLY_HOST_COLOR:=$(tput setaf 255)}
: ${SEAFLY_GIT_COLOR:=$(tput setaf 147)}
: ${SEAFLY_PATH_COLOR:=$(tput setaf 150)}
: ${NOCOLOR:=$(tput sgr0)}

# Shorten directory paths to a maximum of four components unless PROMPT_DIRTRIM
# has already been set.
: ${PROMPT_DIRTRIM:=4}

# Default Git indicator values.
: ${GIT_PS1_SHOWDIRTYSTATE:=1}
: ${GIT_PS1_SHOWSTASHSTATE:=1}
: ${GIT_PS1_SHOWUPSTREAM:=1}

# Default layout settings.
: ${SEAFLY_SHOW_USER:=0}
: ${SEAFLY_LAYOUT:=1}

# Default symbols used in the prompt.
: ${SEAFLY_PROMPT_SYMBOL:="❯"}
: ${SEAFLY_PS2_PROMPT_SYMBOL:="❯"}
: ${SEAFLY_GIT_PREFIX:=""}
: ${SEAFLY_GIT_SUFFIX:=""}
: ${SEAFLY_GIT_DIRTY:="✗"}
: ${SEAFLY_GIT_STAGED:="✓"}
: ${SEAFLY_GIT_STASH:="⚑"}
: ${SEAFLY_GIT_AHEAD:="↑"}
: ${SEAFLY_GIT_BEHIND:="↓"}
: ${SEAFLY_GIT_DIVERGED:="↕"}

# Location of [gitstatus](https://github.com/romkatv/gitstatus).
: ${SEAFLY_GITSTATUS_DIR:="$HOME/.gitstatus"}

# Optional command to run before every prompt; output is ignored.
: ${SEAFLY_PRE_COMMAND:=""}
# Optional command that outputs as the prompt prefix.
: ${SEAFLY_PROMPT_PREFIX:=""}

# Collate Git details using the optimized
# [gitstatus](https://github.com/romkatv/gitstatus) command.
#
_seafly_git_optimized() {
    local flags
    # Note, gitstatus will automatically set '-p' if the local repository has
    # set 'bash.showDirtyState' to false.
    [[ $GIT_PS1_SHOWDIRTYSTATE == 0  ]] && flags=-p # Avoid unnecessary work
    if ! hash gitstatus_query 2>/dev/null || ! gitstatus_query $flags; then
        # Either gitstatus_query does not exist or it failed, use fallback
        # instead.
        _seafly_git_fallback
        return
    fi
    [[ $VCS_STATUS_RESULT == ok-sync ]] || return

    # We are in a Git repository and gitstatus_query succeeded.
    local branch=$VCS_STATUS_LOCAL_BRANCH
    if [[ -z $branch ]]; then
        branch="detached*$(git rev-parse --short HEAD 2>/dev/null)"
    fi
    branch=${branch//\\/\\\\}  # Escape backslashes
    branch=${branch//\$/\\\$}  # Escape dollars

    local dirty
    local staged
    if [[ $GIT_PS1_SHOWDIRTYSTATE != 0 && $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
        dirty=$SEAFLY_GIT_DIRTY
    fi
    if [[ $GIT_PS1_SHOWDIRTYSTATE != 0 && $VCS_STATUS_HAS_STAGED == 1 ]]; then
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
        elif [[ -n $VCS_STATUS_REMOTE_NAME ]]; then
            upstream="="
        fi
    fi

    local spacer
    if [[ -n $dirty || -n $staged || -n $stash || -n $upstream ]]; then
        spacer=" "
    fi
    _seafly_git=" $SEAFLY_GIT_PREFIX$branch$spacer\[$SEAFLY_ALERT_COLOR\]$dirty\[$SEAFLY_NORMAL_COLOR\]$staged$upstream\[$SEAFLY_GIT_COLOR\]$stash$SEAFLY_GIT_SUFFIX"
}

# Collate Git details using just the 'git' command.
#
_seafly_git_fallback() {
    local is_git_repo
    if [[ $(git rev-parse --is-inside-work-tree --is-bare-repository 2>/dev/null) =~ true ]]; then
        is_git_repo=1
    fi
    [[ $is_git_repo == 1 ]] || return

    # We are in a Git repository.
    local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [[ $branch == "HEAD" ]]; then
        branch="detached*$(git rev-parse --short HEAD 2>/dev/null)"
    fi
    branch=${branch//\\/\\\\}  # Escape backslashes
    branch=${branch//\$/\\\$}  # Escape dollars

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
    _seafly_git=" $SEAFLY_GIT_PREFIX$branch$spacer\[$SEAFLY_ALERT_COLOR\]$dirty\[$SEAFLY_NORMAL_COLOR\]$staged$upstream\[$SEAFLY_GIT_COLOR\]$stash$SEAFLY_GIT_SUFFIX"
}

_seafly_command_prompt() {
    # Run the pre-command if set.
    eval $SEAFLY_PRE_COMMAND

    local prompt_prefix
    local prefix_value=$(eval $SEAFLY_PROMPT_PREFIX)
    if [[ -n $prefix_value ]]; then
        prompt_prefix="\[$SEAFLY_PREFIX_COLOR\]$prefix_value "
    fi

    local prompt_start
    if [[ $SEAFLY_SHOW_USER = 1 ]]; then
        prompt_start="\[$SEAFLY_HOST_COLOR\]\u@\h"
    else
        prompt_start="\[$SEAFLY_HOST_COLOR\]\h"
    fi

    # Collate Git details, if applicable, for the current directory.
    _seafly_git_optimized

    local prompt_middle
    if [[ $SEAFLY_LAYOUT = 1 ]]; then
        prompt_middle="\[$SEAFLY_GIT_COLOR\]$_seafly_git\[$SEAFLY_PATH_COLOR\] \w"
    else
        prompt_middle="\[$SEAFLY_PATH_COLOR\] \w\[$SEAFLY_GIT_COLOR\]$_seafly_git"
    fi
    unset _seafly_git

    # Normal prompt indicates that the last command ran successfully.
    # Alert prompt indicates that the last command failed.
    _seafly_colors=("$SEAFLY_ALERT_COLOR" "$SEAFLY_NORMAL_COLOR")
    local prompt_end="\[\${_seafly_colors[\$((!\$?))]}\] $SEAFLY_PROMPT_SYMBOL\[\$NOCOLOR\] "

    PS1="$prompt_prefix$prompt_start$prompt_middle$prompt_end"
    PS2="\[$SEAFLY_NORMAL_COLOR\]$SEAFLY_PS2_PROMPT_SYMBOL\[\$NOCOLOR\] "
}

# Use [gitstatus](https://github.com/romkatv/gitstatus) if it is available.
if [[ -r $SEAFLY_GITSTATUS_DIR/gitstatus.plugin.sh ]]; then
    source "$SEAFLY_GITSTATUS_DIR"/gitstatus.plugin.sh
    gitstatus_stop && gitstatus_start -c 0 -d 0
fi

# Bind and call the '_seafly_command_prompt' function as the Bash prompt.
PROMPT_COMMAND=_seafly_command_prompt
