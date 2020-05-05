

#!/bin/sh
#
# Adapted from https://github.com/robbyrussell/oh-my-zsh.git
#

main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e
  
  printf "${BOLD}Updating Shell Environment.\n${NORMAL}"
  printf "${BLUE}Checking for previously-installed environment...\n${NORMAL}"
  if [ ! -n "$ENVGIT" ]; then
    ENVGIT=~/.env.git
  fi
  if [ -d "$ENVGIT" ]; then
    printf "${GREEN}\tFound at '$ENVGIT'.\n${NORMAL}"
  else
    printf "${YELLOW}\tYou do not have an environment installed.\n${NORMAL}"
    printf "\tYou'll need to install one first before you can update.\n"
    exit 1
  fi
  # Enable fail-on-unset-variable once we have checked for an existing environment
  set -u
  
  # update the env git repo
  pushd "$ENVGIT"
  git pull
  popd
  
  # re-link all files from the env git repo into the home directory
  source "$ENVGIT/link.sh"
  
  # remove memoized profile so it will be regenerated
  if [ -e ~/.profile.memoized ]; then
    printf "${BLUE}Resetting memoized profile...\n${NORMAL}"
    rm ~/.profile.memoized
  fi
  
  # Re-clone the PowerLevel10k ZSH theme
  rm -rf "$ENVGIT"/dotfiles/oh-my-zsh/custom/themes/powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ENVGIT"/dotfiles/oh-my-zsh/custom/themes/powerlevel10k
  
  # If this user's login shell is not already "zsh", attempt to switch.
  printf "${BLUE}Verifying that your shell is zsh...\n${NORMAL}"
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      printf "${GREEN}\tChanging your default shell to zsh.\n${NORMAL}"
      chsh -s $(grep /zsh$ /etc/shells | tail -1)
    # Else, suggest the user do so manually.
    else
      printf "${RED}\tCannot change your shell automatically because this system does not have chsh.\n${NORMAL}"
      printf "\tPlease manually change your default shell to zsh.\n"
    fi
  else
    printf "${GREEN}\tYour current shell is already ${TEST_CURRENT_SHELL}\n${NORMAL}"
  fi
  
  printf "${BOLD}Shell Environment successfully installed.\n${NORMAL}"
  printf "${BLUE}Memoizing new profile...\n${NORMAL}"
  env zsh -l
}

main
