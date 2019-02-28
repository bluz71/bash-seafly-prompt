# seafly

_seafly_ is a modern, informative and configurable command prompt for the
[Bash](https://www.gnu.org/software/bash) shell.

Inspiration provided by:

-   [Pure ZSH](https://github.com/sindresorhus/pure)
-   [bash-git-prompt](https://github.com/magicmonty/bash-git-prompt)
-   [sapegin/dotfiles Bash prompt](https://github.com/sapegin/dotfiles/blob/dd063f9c30de7d2234e8accdb5272a5cc0a3388b/includes/bash_prompt.bash)

## Screenshot

<img width="800" alt="seafly" src="https://raw.githubusercontent.com/bluz71/misc-binaries/master/seafly/seafly.png">

The font in use is [Iosevka](https://github.com/be5invis/Iosevka).

## Layout

_seafly_ is a single line prompt that is divided into the following segments:

```
<Optional Prefix> <Host> <Git Branch> <Git Indicators> <Current Path> <Prompt Symbol>
```

Note, when `SEAFLY_LAYOUT=2` is set the prompt will be:

```
<Optional Prefix> <Host> <Current Path> <Git Branch> <Git Indicators> <Prompt Symbol>
```

Please refer to the configuration section below for more details.

## Behaviour

-   When in a Git repository the checked out Git branch will be displayed.

-   When in a Git repository, dirty state, upstream and stash indicators will be
    displayed. Note, these can individually be disabled if desired.

-   The prompt symbol will change to an alert color, by default red, if the last
    command did not execute successfully.

## Visuals

_seafly_ by default will use Unicode characters for the prompt symbol and
certain Git indicators. These symbols will display correctly in modern fonts
such as [Hack](https://github.com/source-foundry/Hack) or
[Iosevka](https://github.com/be5invis/Iosevka).

Also, _seafly_ by default will use colors that favour a dark background.

Both the symbols and colors used by _seafly_ can be overridden, please refer to
the configuration section below. As an example, the following configuration
will:

-   only use ASCII characters
-   use colors appropriate for a light terminal theme
-   style the Git section to mimic `$(__git_ps1)` provided by the
    [`git-prompt.sh` script](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh)
    that ships with Git

```sh
SEAFLY_PROMPT_SYMBOL=">"
SEAFLY_PS2_PROMPT_SYMBOL=">"
SEAFLY_GIT_PREFIX="("
SEAFLY_GIT_SUFFIX=")"
SEAFLY_GIT_DIRTY="*"
SEAFLY_GIT_STASH="$"
SEAFLY_GIT_AHEAD=">"
SEAFLY_GIT_BEHIND="<"
SEAFLY_GIT_DIVERGED="<>"
SEAFLY_NORMAL_COLOR="$(tput setaf 63)"
SEAFLY_ALERT_COLOR="$(tput setaf 202)"
SEAFLY_HOST_COLOR="$(tput setaf 242)"
SEAFLY_GIT_COLOR="$(tput setaf 99)"
SEAFLY_PATH_COLOR="$(tput setaf 70)"
. ~/.bash-seafly-prompt/command_prompt.bash
```

## Requirements

A modern 256 or true color terminal is required.

Please also make sure the `TERM` environment variable is set to either
`xterm-256color` or `screen-256color`.

Setting `TERM` to `xterm-256color` is usually done at the terminal level
either in a preferences dialog or a related configuration file, if required at
all. Note, some modern terminals will automatically set 256 colors by default,
for example, modern versions of [Gnome
Terminal](https://wiki.gnome.org/Apps/Terminal).

Setting `TERM` to `screen-256color` should only be done for
[tmux](https://github.com/tmux/tmux/wiki) sessions. If you are a tmux user then
please add the following to your `~/.tmux.conf` file:

```
set -g default-terminal "screen-256color"
set -ga terminal-overrides ',xterm-256color:Tc'
```

## Installation

Install the _seafly_ prompt script:

```sh
git clone --depth 1 https://github.com/bluz71/bash-seafly-prompt ~/.bash-seafly-prompt
```

Source the _seafly_ prompt script in your `~/.bashrc` file:

```sh
. ~/.bash-seafly-prompt/command_prompt.bash
```

Note, to update to the latest version of _seafly_:

```sh
cd ~/.bash-seafly-prompt
git pull
```

## Configuration

Certain behaviours and visuals of the _seafly_ prompt can be controlled
through environment variables.

Note, a dash character denotes an unset default value.

### Behaviour

| Option                       | Description                                                                                                                                                 | Default Value |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| **`SEAFLY_PRE_COMMAND`**     | A command to run each time the prompt is displayed.<br>Please make sure any pre-command is very fast.<br>For example, `"history -a"`.                       | -             |
| **`SEAFLY_PROMPT_PREFIX`**   | A shell script snippet to populate the _optional prefix_ segment.<br>Please make sure the script snippet is simple and fast<br>Refer to the examples below. | -             |
| **`SEAFLY_SHOW_USER`**       | Display the current user in the host segment.<br>Set to `1` to display the user.                                                                            | 0             |
| **`SEAFLY_LAYOUT`**          | Specify the preferred layout.<br>Layout `1` will display Git details followed by path.<br>Layout `2` will flip the Git details and path.                    | 1             |
| **`PROMPT_DIRTRIM`**         | Shorten the current directory path to a set maximum number of components.<br>Set to `0` to not shorten the current path.                                    | 4             |
| **`GIT_PS1_SHOWDIRTYSTATE`** | Indicate the presence of Git modifications.<br>Set to `0` to skip.                                                                                          | 1             |
| **`GIT_PS1_SHOWSTASHSTATE`** | Indicate the presence of Git stashes.<br>Set to `0` to skip.                                                                                                | 1             |
| **`GIT_PS1_SHOWUPSTREAM`**   | Indicate differences exist between HEAD and upstream in a Git remote-tracking branch.<br>Set to `0` to skip.                                                | 1             |

:gift: A few **`SEAFLY_PROMPT_PREFIX`** examples:

-   When using the [chruby](https://github.com/postmodern/chruby) Ruby version
    manager and when in a Ruby project base directory display the current
    Ruby version within parenthesis:

    ```sh
    SEAFLY_PROMPT_PREFIX='if [[ -f Gemfile ]]; then echo "($(chruby | grep "*" | cut -d" " -f3))"; fi'
    ```

-   When in an active Python [Virtual
    Environment](https://realpython.com/python-virtual-environments-a-primer)
    display the name of the current environment within parenthesis:

    ```sh
    SEAFLY_PROMPT_PREFIX='if [[ -n $VIRTUAL_ENV ]]; then echo "($(basename $VIRTUAL_ENV))"; fi'
    ```

:bomb: In certain Git repositories, calculating dirty-state can be slow,
either due to the size of the repository or the speed of the file-system
hosting the repository. If so, the prompt will render slowly. One can either
set `GIT_PS1_SHOWDIRTYSTATE=0` to disable dirty-state indication for all
repositories, or if only a few repositories have performance issues then one
can do the following to skip dirty-state indication on a per-repository basis:

```sh
% git config bash.showDirtyState false
```

### Symbols

| Option                         | Description                                                                           | Default Value |
| ------------------------------ | ------------------------------------------------------------------------------------- | ------------- |
| **`SEAFLY_PROMPT_SYMBOL`**     | The prompt symbol                                                                     | ❯             |
| **`SEAFLY_PS2_PROMPT_SYMBOL`** | The `PS2` secondary prompt symbol                                                     | ❯             |
| **`SEAFLY_GIT_PREFIX`**        | Symbol to the left of the Git branch                                                  | -             |
| **`SEAFLY_GIT_SUFFIX`**        | Symbol to the right of the Git indicators                                             | -             |
| **`SEAFLY_GIT_DIRTY`**         | Symbol indicating that a Git repository contains modifications                        | ✗             |
| **`SEAFLY_GIT_STAGED`**        | Symbol indicating that a Git repository contains staged changes                       | ✓             |
| **`SEAFLY_GIT_STASH`**         | Symbol indicating that a Git repository contains one or more stashes                  | ⚑             |
| **`SEAFLY_GIT_AHEAD`**         | Symbol indicating that a Git remote-tracking branch is ahead of upstream              | ↑             |
| **`SEAFLY_GIT_BEHIND`**        | Symbol indicating that a Git remote-tracking branch is behind upstream                | ↓             |
| **`SEAFLY_GIT_DIVERGED`**      | Symbol indicating that a Git remote-tracking branch is both ahead and behind upstream | ↕             |

### Colors

The default color values listed below, such as `111` and `203`, derive from
xterm 256 color values. Please refer to [this
chart](https://jonasjacek.github.io/colors) when customizing _seafly_ colors.

| Option                    | Description                                  | Default Value       | Color                                                   |
| ------------------------- | -------------------------------------------- | ------------------- | ------------------------------------------------------- |
| **`SEAFLY_PREFIX_COLOR`** | _Optional prefix_ segment                    | `$(tput setaf 153)` | ![normal](https://placehold.it/32/afd7ff/000000?text=+) |
| **`SEAFLY_NORMAL_COLOR`** | Normal prompt and certain Git indicators     | `$(tput setaf 111)` | ![normal](https://placehold.it/32/87afff/000000?text=+) |
| **`SEAFLY_ALERT_COLOR`**  | Alert prompt and Git dirty indicator         | `$(tput setaf 203)` | ![normal](https://placehold.it/32/ff5f5f/000000?text=+) |
| **`SEAFLY_HOST_COLOR`**   | Host segment                                 | `$(tput setaf 255)` | ![normal](https://placehold.it/32/eeeeee/000000?text=+) |
| **`SEAFLY_GIT_COLOR`**    | Git branch, stash and optional prefix/suffix | `$(tput setaf 147)` | ![normal](https://placehold.it/32/afafff/000000?text=+) |
| **`SEAFLY_PATH_COLOR`**   | Current directory path                       | `$(tput setaf 150)` | ![normal](https://placehold.it/32/afd787/000000?text=+) |

## License

[MIT](https://opensource.org/licenses/MIT)
