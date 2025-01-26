![seafly](https://raw.githubusercontent.com/bluz71/misc-binaries/master/headings/seafly.png)
========

_seafly_ is a clean and fast command prompt for the
[Bash](https://www.gnu.org/software/bash) shell heavily inspired by the [Pure
ZSH](https://github.com/sindresorhus/pure) prompt.

:rocket: For maximum repository performance, _seafly_ will use, if available,
either the [git-status-fly](https://github.com/bluz71/git-status-fly) or
[git-status-snap](https://github.com/bluz71/git-status-snap) utilities. Note, it
is strongly recommened to use either of these utilities to accelerate prompt
performance.

Screenshot
----------

<img width="800" alt="seafly" src="https://raw.githubusercontent.com/bluz71/misc-binaries/master/seafly/seafly.png">

The font in use is [Iosevka](https://github.com/be5invis/Iosevka).

Layout
------

_seafly_ is a prompt that displays the following segments when using the
default layout:

```
<Optional Prefix> <Optional User/Host> <Current Path> <Git Branch> <Git Indicators> <Prompt Symbol>
```

Note, when `SEAFLY_LAYOUT=2` is set the prompt will instead display as:

```
<Optional Prefix> <Optional User/Host> <Git Branch> <Git Indicators> <Current Path> <Prompt Symbol>
```

_seafly_ can also display as a multiline prompt when `SEAFLY_MULTILINE=1` is
set. The layout will be the same as listed above but with additional newlines
prior to the prefix and prompt symbol.

Please refer to the configuration section below for more details.

Behaviour
---------

- When in a Git repository the checked out Git branch will be displayed.

- When in a Git repository, dirty state, upstream and stash indicators will be
  displayed. Note, these can individually be disabled if desired.

- The prompt symbol will change to an alert color, by default red, if the last
  command did not execute successfully.

Visuals
-------

_seafly_ by default will use Unicode characters for the prompt symbol and
certain Git indicators. These symbols will display correctly when using a modern
font such as [Iosevka](https://github.com/be5invis/Iosevka).

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
SEAFLY_SUCCESS_COLOR="$(tput setaf 63)"
SEAFLY_ALERT_COLOR="$(tput setaf 202)"
SEAFLY_HOST_COLOR="$(tput setaf 242)"
SEAFLY_GIT_COLOR="$(tput setaf 99)"
SEAFLY_PATH_COLOR="$(tput setaf 70)"
. ~/.bash-seafly-prompt/command_prompt.bash
```

Requirements
------------

A modern 256 or true color terminal is required.

Please also make sure the `TERM` environment variable is set to
`xterm-256color`, `screen-256color` or equivalent terminal setting.

For example setting `TERM` to `xterm-256color` is usually done at the terminal
level either in a preferences dialog or a related configuration file, if
required at all. Note, some modern terminals will automatically set 256 colors
by default, for example, modern versions of [Gnome
Terminal](https://wiki.gnome.org/Apps/Terminal).

Setting `TERM` to `screen-256color` should only be done for
[tmux](https://github.com/tmux/tmux/wiki) sessions. If you are a tmux user then
please add the following to your `~/.tmux.conf` file:

```
set -g default-terminal "screen-256color"
set -ga terminal-overrides ',xterm-256color:Tc'
```

Note, modern terminals such as [Alacritty](https://github.com/alacritty) and
[kitty](https://sw.kovidgoyal.net/kitty) provide their own terminfo definitions
which are also supported by _seafly_ prompt.

Installation
------------

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

git-status-fly
--------------

The [git-status-fly](https://github.com/bluz71/git-status-fly) utility is a
simple [Rust](https://www.rust-lang.org) implemented `git status` parser.
Processing the output of `git status` using shell commands, such as `grep` and
`awk`, is much slower than using an optimized binary such as _git-status-fly_.

Install the _git-status-fly_ somewhere in the current `$PATH`.

git-status-snap
--------------

The [git-status-snap](https://github.com/bluz71/git-status-snap) utility is an
alternative [Crystal](https://crystal-lang.org) implemented `git status` parser.
Implementation and behaviour is the same as _git-status-fly_.

Install the _git-status-snap_ somewhere in the current `$PATH`.

Git Performance
---------------

_seafly_ provides two ways to gather Git status, the previously mentioned
_git-status-fly_ or _git-status-snap_ utilities, or a fallback method which
collates details using just the `git` command.

Which to use? See the following performance results and decide.

Performance metrics are listed for the following four repositories:

- _dotfiles_, small repository with 189 managed files
- _rails_, medium repository with 4,574 managed files
- _linux_, large repository with 79,878 managed files
- _chromium_, extra large repository with 413,542 managed files

Listed is the average time to compute the prompt function.

Linux desktop with NVMe storage:

| Repository     | `git-status-fly` | `git-status-snap` | `git` fallback |
|----------------|------------------|-------------------|----------------|
| _dotfiles_     | `5ms`            | `6ms`             | `11ms`         |
| _rails_        | `7ms`            | `7ms`             | `14ms`         |
| _linux_(*)     | `26ms`           | `26ms`            | `38ms`         |
| _chromium_ (*) | `122ms`          | `123ms`           | `154ms`        |

M1 Macbook Air:

| Repository     | `git-status-fly` | `git-status-snap` | `git` fallback |
|----------------|------------------|-------------------|----------------|
| _dotfiles_     | `33ms`           | `39ms`            | `61ms`         |
| _rails_        | `39ms`           | `43ms`            | `73ms`         |
| _linux_ (!)    | `60ms`           | `64ms`            | `105ms`        |
| _chromium_ (!) | `103ms`          | `108ms`           | `155ms`        |

- **(*)**, the `git config feature.manyFiles true` option was enabled  as
  [documented here](https://github.blog/2019-11-03-highlights-from-git-2-24/)

- **(!)**, in addition to enabling `manyFiles`, the `git config core.fsmonitor
  true` file system monitor was also enabled as [documented
  here](https://github.blog/2022-06-29-improve-git-monorepo-performance-with-a-file-system-monitor)

Note, as of May 2023 `fsmonitor` is implemented only for Windows and macOS, it
is not available for Linux.

In practise, a prompt startup time under 40ms feels instant.

Configuration
-------------

Certain behaviours and visuals of the _seafly_ prompt can be controlled
through environment variables.

Note, a dash character denotes an unset default value.

### Environment Variables

| Option                               | Description                                                                                                                               | Default Value |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------| ------------- |
| **`SEAFLY_LAYOUT`**                  | Specify the preferred layout.<br>Layout `1` will display path followed Git details.<br>Layout `2` will flip the path and Git details.     | 1             |
| **`SEAFLY_MULTILINE`**               | Specify multiline layout.<br>`SEAFLY_MULTILINE=1` will display the prompt over multiple lines.                                            | 0             |
| **`SEAFLY_SHOW_USER`**               | Display the current user in the user/host segment.<br>Set to `1` to display the user.<br>Refer to `SEAFLY_SHOW_USERHOST_CONNECTED`.       | 0             |
| **`SEAFLY_SHOW_HOST`**               | Display the current hostname in the user/host segment.<br>Set to `0` to not display the host.<br>Ref to `SEAFLY_SHOW_USERHOST_CONNECTED`. | 1             |
| **`SEAFLY_SHOW_USERHOST_CONNECTED`** | Display the user/host segment only when connected to external hosts.<br>Set to `0` to always the user/host segment.                       | 1             |
| **`PROMPT_DIRTRIM`**                 | Shorten the current directory path to a set maximum number of components.<br>Set to `0` to not shorten the current path.                  | 4             |
| **`GIT_PS1_SHOWDIRTYSTATE`**         | Indicate the presence of Git modifications.<br>Set to `0` to skip.                                                                        | 1             |
| **`GIT_PS1_SHOWSTASHSTATE`**         | Indicate the presence of Git stashes.<br>Set to `0` to skip.                                                                              | 1             |
| **`GIT_PS1_SHOWUPSTREAM`**           | Indicate differences exist between HEAD and upstream in a Git remote-tracking branch.<br>Set to `0` to skip.                              | 1             |

### Hooks

| Hook                             | Description                                                                                                 | Default Value |
| ---------------------------------| ------------------------------------------------------------------------------------------------------------| ------------- |
| **`seafly_pre_command_hook`**    | A function hook to run each time the prompt is displayed.<br>Please make sure the hook is fast.             | -             |
| **`seafly_prompt_prefix_hook`**  | A function hook to populate the _optional prefix_ segment.<br>Please make sure the hook is simple and fast. | -             |

- A **`pre_command_hook`** example that appends and updates history each time
  the prompt is executed:

  ```bash
  seafly_pre_command_hook="seafly_pre_command"

  seafly_pre_command() {
      history -a && history -n
  }
  ```

- A **`prompt_prefix_hook`** example that displays the current Node version if
  `package.json` file is present or displays the name of the current Python
  virtual environment if one is active in the _optional prefix_ segment:

  ```bash
  seafly_prompt_prefix_hook="seafly_prompt_prefix"

  seafly_prompt_prefix() {
      if [[ -f package.json ]]; then
          echo "($(nvm current))"
      elif [[ -n $VIRTUAL_ENV ]]; then
          echo "($(basename $VIRTUAL_ENV))"
      fi
  }
  ```

### Symbols

| Option                         | Description                                                                           | Default Value |
| ------------------------------ | ------------------------------------------------------------------------------------- | ------------- |
| **`SEAFLY_PROMPT_SYMBOL`**     | The prompt symbol                                                                     | ❯             |
| **`SEAFLY_PS2_PROMPT_SYMBOL`** | The `PS2` secondary prompt symbol                                                     | ❯             |
| **`SEAFLY_GIT_PREFIX`**        | Symbol to the left of the Git branch                                                  |              |
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

| Option                     | Description                                  | Default Value | Color                                             |
| -------------------------- | -------------------------------------------- | ------------- | ------------------------------------------------- |
| **`SEAFLY_PREFIX_COLOR`**  | _Optional prefix_ segment                    | `217`         | ![normal](https://place-hold.it/32/5fd7af?text=+) |
| **`SEAFLY_SUCCESS_COLOR`** | Standard prompt and certain Git indicators   | `111`         | ![normal](https://place-hold.it/32/87afff?text=+) |
| **`SEAFLY_ALERT_COLOR`**   | Alert prompt and Git dirty indicator         | `203`         | ![normal](https://place-hold.it/32/ff5f5f?text=+) |
| **`SEAFLY_HOST_COLOR`**    | Host segment                                 | `255`         | ![normal](https://place-hold.it/32/eeeeee?text=+) |
| **`SEAFLY_GIT_COLOR`**     | Git branch, stash and optional prefix/suffix | `147`         | ![normal](https://place-hold.it/32/afafff?text=+) |
| **`SEAFLY_PATH_COLOR`**    | Current directory path                       | `114`         | ![normal](https://place-hold.it/32/87d787?text=+) |

Sponsor
-------

[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/bluz71)

License
-------

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
