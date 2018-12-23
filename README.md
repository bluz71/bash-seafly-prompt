seafly
======

*seafly* is a modern and informative command prompt for the
[Bash](https://www.gnu.org/software/bash) shell.

Requirements
------------

A modern 256 or true color terminal is required. Please make sure the `$TERM`
environment variable is set to either `xterm-256color` or `screen-256color`.

Setting `$TERM` to `xterm-256color` is usually done at the terminal level
either in a preferences dialog or a related configuation file, if required at
all. Note, some modern terminals will automatically set 256 colors by default,
for instance, modern versions of [Gnome
Terminal](https://wiki.gnome.org/Apps/Terminal).

Setting `$TERM` to `screen-256color` should only be done for
[tmux](https://github.com/tmux/tmux/wiki) sessions. If you are a tmux user then
please add the following to your `~/.tmux.conf` file:

```
set -g default-terminal "screen-256color"
set -ga terminal-overrides ',xterm-256color:Tc'
```

Installation
------------

Install the *seafly* prompt script:

```sh
git clone --depth 1 https://github.com/bluz71/bash-seafly-prompt ~/.bash-seafly-prompt
```

Source the *seafly* prompt script in your `~/.bashrc`:

```sh
. ~/.bash-seafly-prompt/command_prompt.bash
```

Note, to update to the latest version of *seafly*:

```sh
cd ~/.bash-seafly-prompt
git pull
```

Layout
------

Todo.

Configuration
-------------

Certain behaviours and visuals of the *seafly* prompt can be controlled
through environment variables. 

Note, '-' denotes an unset value.

### Behaviour

| Option | Description | Default Value
|--------|-------------|--------------
| **`SEAFLY_PRE_COMMAND`** | A command to run each time the prompt is displayed. For example `history -a`. Please make sure the pre-command is small and very fast. | -
| **`GIT_PS1_SHOWDIRTYSTATE`** | Indicate the presence of modifications in a Git repository. Set to `0` to skip. | 1
| **`GIT_PS1_SHOWSTASHSTATE`** | Indicate the presence of stashes in a Git repository. Set to `0` to skip. | 1
| **`GIT_PS1_SHOWUPSTREAM`** | Indicate differences between HEAD and upstream in a Git repository. Set to `0` to skip. | 1

In certain Git repositories, calculating dirty-state can sometimes be slow,
either due to the size of the repository or the speed of the file-system
hosting the repository. If so, the prompt will appear slow to render. One can
either set `GIT_PS1_SHOWDIRTYSTATE=0` for all repositories or if only a few
repositories have issues then one can do the following to skip dirty-state
computation on a per-repository basis:

```sh
% git config bash.showDirtyState false
```

### Symbols

| Option | Description | Default Value
|--------|-------------|--------------
| **`SEAFLY_PROMPT_SYMBOL`** | The prompt symbol | ❯
| **`SEAFLY_GIT_LEFT_DELIM`** | The symbol to display on the left-side of the Git stanza | -
| **`SEAFLY_GIT_RIGHT_DELIM`** | The symbol to display on the right-side of the Git stanza | -
| **`SEAFLY_GIT_DIRTY`** | Symbol indicating that a Git repository contains modifications | ✗
| **`SEAFLY_GIT_STAGED`** | Symbol indicating that a Git repository contains staged changes | ✓
| **`SEAFLY_GIT_STASH`** | Symbol indicating that a Git repository contains one or more stashes | ⚑
| **`SEAFLY_GIT_AHEAD`** | Symbol indicating that a Git remote-tracking branch contains commits ahead of upstream | ↑
| **`SEAFLY_GIT_BEHIND`** | Symbol indicating that a Git remote-tracking branch is missing commit from upstream | ↓
| **`SEAFLY_GIT_DIVERGED`** | Symbol indicating that a Git remote-tracking branch is both ahead and behind upstream | ↕

License
-------

[MIT](https://opensource.org/licenses/MIT)
