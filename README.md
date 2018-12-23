seafly
======

*seafly* is a modern and informative command prompt for the
[Bash](https://www.gnu.org/software/bash) shell.

Inspiration provided by:

* [Pure ZSH](https://github.com/sindresorhus/pure)
* [bash-git-prompt](https://github.com/magicmonty/bash-git-prompt)
* [sapegin/dotfiles Bash prompt](https://github.com/sapegin/dotfiles/blob/dd063f9c30de7d2234e8accdb5272a5cc0a3388b/includes/bash_prompt.bash)

Screenshot
----------

Todo

Layout & Behaviour
------------------

Todo.

Red prompt symbol and blue prompt symbol.

Requirements
------------

A modern 256 or true color terminal is required.

Please also make sure the `TERM` environment variable is set to either
`xterm-256color` or `screen-256color`.

Setting `TERM` to `xterm-256color` is usually done at the terminal level
either in a preferences dialog or a related configuation file, if required at
all. Note, some modern terminals will automatically set 256 colors by default,
for instance, modern versions of [Gnome
Terminal](https://wiki.gnome.org/Apps/Terminal).

Setting `TERM` to `screen-256color` should only be done for
[tmux](https://github.com/tmux/tmux/wiki) sessions. If you are a tmux user then
please add the following to your `~/.tmux.conf` file:

```
set -g default-terminal "screen-256color"
set -ga terminal-overrides ',xterm-256color:Tc'
```

Recommendation
--------------

Todo: a modern font.

Installation
------------

Install the *seafly* prompt script:

```sh
git clone --depth 1 https://github.com/bluz71/bash-seafly-prompt ~/.bash-seafly-prompt
```

Source the *seafly* prompt script in your `~/.bashrc` file:

```sh
. ~/.bash-seafly-prompt/command_prompt.bash
```

Note, to update to the latest version of *seafly*:

```sh
cd ~/.bash-seafly-prompt
git pull
```

Configuration
-------------

Certain behaviours and visuals of the *seafly* prompt can be controlled
through environment variables.

Note, '-' denotes an unset value.

### Behaviour

| Option | Description | Default Value
|--------|-------------|--------------
| **`SEAFLY_PRE_COMMAND`** | A command to run each time the prompt is displayed.<br>For example `history -a`.<br>Please make sure any pre-command is very fast. | -
| **`GIT_PS1_SHOWDIRTYSTATE`** | Indicate the presence of Git modifications.<br>Set to `0` to skip. | 1
| **`GIT_PS1_SHOWSTASHSTATE`** | Indicate the presence of Git stashes.<br>Set to `0` to skip. | 1
| **`GIT_PS1_SHOWUPSTREAM`** | Indicate differences exist between HEAD and upstream in a Git remote-tracking branch.<br>Set to `0` to skip. | 1

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

| Option | Description | Default Value
|--------|-------------|--------------
| **`SEAFLY_PROMPT_SYMBOL`** | The prompt symbol | ❯
| **`SEAFLY_GIT_PREFIX`** | Left-side delimiter symbol of the Git prompt section | -
| **`SEAFLY_GIT_SUFFIX`** | Right-side delimiter symbol of the Git prompt section | -
| **`SEAFLY_GIT_DIRTY`** | Symbol indicating that a Git repository contains modifications | ✗
| **`SEAFLY_GIT_STAGED`** | Symbol indicating that a Git repository contains staged changes | ✓
| **`SEAFLY_GIT_STASH`** | Symbol indicating that a Git repository contains one or more stashes | ⚑
| **`SEAFLY_GIT_AHEAD`** | Symbol indicating that a Git remote-tracking branch is ahead of upstream | ↑
| **`SEAFLY_GIT_BEHIND`** | Symbol indicating that a Git remote-tracking branch is behind upstream | ↓
| **`SEAFLY_GIT_DIVERGED`** | Symbol indicating that a Git remote-tracking branch is both ahead and behind upstream | ↕

License
-------

[MIT](https://opensource.org/licenses/MIT)
