# A colorful Bash prompt.
#
# Note: Inspiration taken from: Pure Zsh theme and Bash Git Prompt
#
# URL:     github.com/bluz71/dotfiles
# License: MIT (https://opensource.org/licenses/MIT)
#
# Environment variable customizations (set to any non-empty value):
# 
# - SEAFLY_PRE_COMMAND
# - GIT_PS1_SHOWDIRTYSTATE, indicate staged and unstaged modifications
# - GIT_PS1_SHOWSTASHSTATE, indicate precense of stash(es)
# - GIT_PS1_SHOWUPSTREAM, indicate upstream and downstream changes
#
# Note, computing Git dirty state can be expensive. If GIT_PS1_SHOWDIRTYSTATE
# is set but you want to disable the dirty indicator on a per-repository
# basis then please set the following repository configuration:
#
#  % git config bash.showDirtyState false


_interactive_terminal=0
if [[ "$-" =~ i ]]; then
    _interactive_terminal=1
fi

_color_terminal=0
if [ "$TERM" = "xterm-256color" ] || [ "$TERM" = "screen-256color" ]; then
    _color_terminal=1
fi

# Colors used in the prompt.
if [ $_interactive_terminal = 1 ] && [ $_color_terminal = 1 ]; then
    BLUE="$(tput setaf 111)"
    PURPLE="$(tput setaf 147)"
    GREEN="$(tput setaf 150)"
    RED="$(tput setaf 203)"
    WHITE="$(tput setaf 255)"
    NOCOLOR="$(tput sgr0)"
fi

# Shorten directory paths to a maximum of four components unless PROMPT_DIRTRIM
# has already been set.
if [ -z "$PROMPT_DIRTRIM" ]; then
    PROMPT_DIRTRIM=4
fi

# Symbols used in the prompt.
if [ -z "$SEAFLY_PROMPT_SYMBOL" ]; then
    SEAFLY_PROMPT_SYMBOL="❯"
fi
if [ -z "$SEAFLY_GIT_LEFT_DELIM" ]; then
    SEAFLY_GIT_LEFT_DELIM=""
fi
if [ -z "$SEAFLY_GIT_RIGHT_DELIM" ]; then
    SEAFLY_GIT_RIGHT_DELIM=""
fi
if [ -z "$SEAFLY_GIT_DIRTY" ]; then
    SEAFLY_GIT_DIRTY="✗"
fi
if [ -z "$SEAFLY_GIT_STAGED" ]; then
    SEAFLY_GIT_STAGED="✓"
fi
if [ -z "$SEAFLY_GIT_STASH" ]; then
    SEAFLY_GIT_STASH="⚑"
fi
if [ -z "$SEAFLY_GIT_AHEAD" ]; then
    SEAFLY_GIT_AHEAD="↑"
fi
if [ -z "$SEAFLY_GIT_BEHIND" ]; then
    SEAFLY_GIT_BEHIND="↓"
fi
if [ -z "$SEAFLY_GIT_DIVERGED" ]; then
    SEAFLY_GIT_DIVERGED="↕"
fi

_command_prompt()
{
    # Run a pre-command if set.
    if [ -n "$SEAFLY_PRE_COMMAND" ]; then
        eval $SEAFLY_PRE_COMMAND
    fi

    # Set a simple prompt for non-interactive or non-color terminals.
    if [ $_interactive_terminal = 0 ] || [ $_color_terminal = 0 ]; then
        PS1='\h \w > '
        return
    fi

    local git_details=""
    if [[ "$(git rev-parse --is-inside-work-tree --is-bare-repository 2>/dev/null)" =~ true ]]; then
        local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
        if [ "$branch" = "HEAD" ]; then
            branch="detached*$(git rev-parse --short HEAD 2>/dev/null)"
        fi

        local dirty=""
        local staged=""
        if [ "$branch" != "detached*" ] &&
           [ "$GIT_PS1_SHOWDIRTYSTATE" != 0 ] &&
           [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
            git diff --no-ext-diff --quiet --exit-code --ignore-submodules 2>/dev/null || dirty=$SEAFLY_GIT_DIRTY
            git diff --no-ext-diff --quiet --cached --exit-code --ignore-submodules 2>/dev/null || staged=$SEAFLY_GIT_STAGED
        fi

        local stash=""
        if [ "$GIT_PS1_SHOWSTASHSTATE" != 0 ]; then
            git rev-parse --verify --quiet refs/stash >/dev/null && stash=$SEAFLY_GIT_STASH
        fi

        local upstream=""
        if [ "$GIT_PS1_SHOWUPSTREAM" != 0 ]; then
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

        local spacer=""
        if [ -n "$dirty" ] || [ -n "$staged" ] || [ -n "$stash" ] || [ -n "$upstream" ]; then
            spacer=" "
        fi

        git_details=" $SEAFLY_GIT_LEFT_DELIM$branch$spacer\[$RED\]$dirty\[$BLUE\]$staged\[$BLUE\]$upstream\[$PURPLE\]$stash$SEAFLY_GIT_RIGHT_DELIM"
    fi

    # Blue ❯ indicates that the last command ran successfully.
    # Red ❯ indicates that the last command failed.
    local prompt_end="\$(if [ \$? = 0 ]; then echo \[\$BLUE\]; else echo \[\$RED\]; fi) $SEAFLY_PROMPT_SYMBOL\[\$NOCOLOR\] "

    PS1="\[$WHITE\]\h\[$PURPLE\]$git_details\[$GREEN\] \w$prompt_end"
}

# Bind the '_command_prompt' function as the Bash prompt.
PROMPT_COMMAND=_command_prompt
