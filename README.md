# env
My standard *nix environment set-up

## Installation

The environment template is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`.

#### via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jbagdis/env/master/install.sh)"
```

#### via wget

```shell
sh -c "$(wget https://raw.githubusercontent.com/jbagdis/env/master/install.sh -O -)"
```

## Usage

### Shell

[Zsh](https://www.zsh.org/) is the default shell. It is configured using [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh).

### Memoization

Environment variables created and set by `~/.profile` are stored in `~/.profile.memoized`, and sourced from that file on subsequent shell start-ups to save initialization time.
To reset the memoization, simple delete `~/.profile.memoized` and it will be regenerated the next time you open a login shell.

### Local Customization

Add system-specific customization to `~/.profile.local`. This file will automatically be included by `~/.profile` if it exists.
