# A modern, informative and configurable command prompt for the Bash shell.
#
# URL:     github.com/bluz71/bash-seafly-prompt
# License: MIT (https://opensource.org/licenses/MIT)

[[ "$-" =~ i ]] || return 0  # non-interactive shell doesn't have prompt

# Set a simple prompt for non-color terminals.
if [[ $TERM != *-256color ]]; then
    PS1='\h \w > '
    return
fi

# Colors used in the prompt.
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

: ${SEAFLY_SHOW_USER:=0}
: ${SEAFLY_LAYOUT:=1}
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

# Location of https://github.com/romkatv/gitstatus repo.
: ${SEAFLY_GITSTATUS_DIR:="$HOME/.gitstatus"}

# Optional command to run before every prompt. Its output goes straight to stdout.
: ${SEAFLY_PRE_COMMAND:=""}
# Another optional command to run before every prompt. Its output becomes prompt prefix.
: ${SEAFLY_PROMPT_PREFIX:=""}

: ${GIT_PS1_SHOWDIRTYSTATE:=0}
: ${GIT_PS1_SHOWSTASHSTATE:=0}
: ${GIT_PS1_SHOWUPSTREAM:=0}

# Sets VCS_STATUS_* variables based on the sate of the current Git repository.
#
_seafly_fetch_git_status() {
  local flags
  (( GIT_PS1_SHOWDIRTYSTATE )) || flags=-p  # avoid unnecessary workdir scans

  if hash gitstatus_query 2>/dev/null && gitstatus_query $flags; then
    [[ $VCS_STATUS_RESULT == ok-sync ]] || return
    [[ -z $VCS_STATUS_LOCAL_BRANCH ]] && VCS_STATUS_COMMIT=$(git rev-parse --short HEAD 2>/dev/null)
    return 0
  fi

  # gitstatus_query didn't work; have to fall back to the slow alternative implementation.
  [[ $(git rev-parse --is-inside-work-tree --is-bare-repository 2>/dev/null) =~ true ]] || return

  VCS_STATUS_LOCAL_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ $VCS_STATUS_LOCAL_BRANCH == "HEAD" ]]; then
      VCS_STATUS_LOCAL_BRANCH=""
      VCS_STATUS_COMMIT=$(git rev-parse --short HEAD 2>/dev/null)
  fi

  VCS_STATUS_HAS_UNSTAGED=0
  VCS_STATUS_HAS_STAGED=0
  VCS_STATUS_STASHES=0
  VCS_STATUS_COMMITS_AHEAD=0
  VCS_STATUS_COMMITS_BEHIND=0

  if [[ $GIT_PS1_SHOWDIRTYSTATE != 0 &&
        $(git config --bool bash.showDirtyState 2>/dev/null) != "false" ]]; then
      git diff --no-ext-diff --quiet --exit-code --ignore-submodules 2>/dev/null || VCS_STATUS_HAS_UNSTAGED=1
      git diff --no-ext-diff --quiet --cached --exit-code --ignore-submodules 2>/dev/null || VCS_STATUS_HAS_STAGED=1
  fi

  if (( GIT_PS1_SHOWSTASHSTATE )); then
      git rev-parse --verify --quiet refs/stash >/dev/null && VCS_STATUS_STASHES=1
  fi

  if [[ $GIT_PS1_SHOWUPSTREAM != 0 ]]; then
      local ahead_behind=($(git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null))
      VCS_STATUS_COMMITS_AHEAD=${ahead_behind[0]}
      VCS_STATUS_COMMITS_BEHIND=${ahead_behind[1]}
  fi
}

# Sets _seafly_git_details based on VCS_STATUS_* variables.
#
_seafly_format_git_status() {
    local ref=${VCS_STATUS_LOCAL_BRANCH:-$VCS_STATUS_COMMIT}
    ref=${ref//\\/\\\\}  # escape backslashes
    ref=${ref//\$/\\\$}  # escape dollars

    local dirty staged stash upstream spacer

    (( GIT_PS1_SHOWDIRTYSTATE && VCS_STATUS_HAS_UNSTAGED )) && dirty=$SEAFLY_GIT_DIRTY
    (( GIT_PS1_SHOWDIRTYSTATE && VCS_STATUS_HAS_STAGED ))   && staged=$SEAFLY_GIT_STAGED
    (( GIT_PS1_SHOWSTASHSTATE && VCS_STATUS_STASHES ))      && stash=$SEAFLY_GIT_STASH

    if (( GIT_PS1_SHOWUPSTREAM )); then
        (( VCS_STATUS_COMMITS_AHEAD ))  && upstream=$SEAFLY_GIT_AHEAD
        (( VCS_STATUS_COMMITS_BEHIND )) && upstream=$SEAFLY_GIT_BEHIND
        (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )) && upstream=$SEAFLY_GIT_DIVERGED
    fi

    [[ -n $dirty || -n $staged || -n $stash || -n $upstream ]] && spacer=" "
    _seafly_git_details=" $SEAFLY_GIT_PREFIX$ref$spacer\[$SEAFLY_ALERT_COLOR\]$dirty\[$SEAFLY_NORMAL_COLOR\]$staged$upstream\[$SEAFLY_GIT_COLOR\]$stash$SEAFLY_GIT_SUFFIX"
}

_seafly_prompt_command() {
    eval $SEAFLY_PRE_COMMAND

    PS1=$(eval $SEAFLY_PROMPT_PREFIX)
    PS1=${PS1:+"\[$SEAFLY_PREFIX_COLOR\]$PS1 "}

    PS1+="\[$SEAFLY_HOST_COLOR\]"
    (( SEAFLY_SHOW_USER )) && PS1+="\u@"
    PS1+="\h"

    # Collate Git details, if applicable, for the current directory.
    _seafly_fetch_git_status && _seafly_format_git_status

    if (( SEAFLY_LAYOUT )); then
        PS1+="\[$SEAFLY_GIT_COLOR\]$_seafly_git_details\[$SEAFLY_PATH_COLOR\] \w"
    else
        PS1+="\[$SEAFLY_PATH_COLOR\] \w\[$SEAFLY_GIT_COLOR\]$_seafly_git_details"
    fi

    unset _seafly_git_details

    # Normal prompt indicates that the last command ran successfully.
    # Alert prompt indicates that the last command failed.
    _seafly_color=("$SEAFLY_ALERT_COLOR" "$SEAFLY_NORMAL_COLOR")
    PS1+="\[\${_seafly_color[\$((!\$?))]}\] $SEAFLY_PROMPT_SYMBOL\[\$NOCOLOR\] "

    PS2="\[$SEAFLY_NORMAL_COLOR\]$SEAFLY_PS2_PROMPT_SYMBOL\[\$NOCOLOR\] "
}

# Use [gitstatus](https://github.com/romkatv/gitstatus) if it is available.
if [[ -r "$SEAFLY_GITSTATUS_DIR"/gitstatus.plugin.sh ]]; then
    source "$SEAFLY_GITSTATUS_DIR"/gitstatus.plugin.sh
    gitstatus_stop && gitstatus_start -c 0 -d 0
fi

# Call '_seafly_prompt_command' function before every prompt.
PROMPT_COMMAND=_seafly_prompt_command
