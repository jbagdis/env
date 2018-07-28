#!/bin/sh
#
# Adapted from https://github.com/robbyrussell/oh-my-zsh.git
#
#ENVGIT=~/env-git

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
  
  printf "${BOLD}Installing Shell Environment.\n${NORMAL}"
  printf "${BLUE}Checking prerequisites...\n${NORMAL}"
  command -v curl >/dev/null 2>&1 && printf "${GREEN}\t'curl' found.\n${NORMAL}" || (printf "${RED}\t'curl' not found.\n${NORMAL}" && exit 1)
  command -v git >/dev/null 2>&1 && printf "${GREEN}\t'git' found.\n${NORMAL}" || (printf "${RED}\t'git' not found.\n${NORMAL}" && exit 1)
  if [ -e ~/.nvm ]; then
    printf "${GREEN}\t'nvm' found.\n${NORMAL}"
  else
    printf "${RED}\t'nvm' not found.\n${NORMAL}"
    exit 1
  fi
  command -v zsh >/dev/null 2>&1 && printf "${GREEN}\t'zsh' found.\n${NORMAL}" || (printf "${RED}\t'zsh' not found.\n${NORMAL}" && exit 1)
  #printf "All prerequisites satisfied.\n"
  
  printf "${BLUE}Checking for previously-installed environment...\n${NORMAL}"
  if [ ! -n "$ENVGIT" ]; then
    ENVGIT=~/.env.git
  fi
  if [ -d "$ENVGIT" ]; then
    printf "${YELLOW}\tYou already have an environment installed.\n${NORMAL}"
    printf "\tYou'll need to remove $ENVGIT if you want to re-install.\n"
    #exit
  else
    printf "${GREEN}\tNone found.\n${NORMAL}"
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning Environment Repository...\n${NORMAL}"
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "${RED}\tError: Windows/MSYS Git is not supported on Cygwin${NORMAL}"
      echo "\tMake sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --progress --depth=1 https://github.com/jbagdis/env.git "$ENVGIT" 2>&1 | sed 's/^/\'$'\t/' || {
    printf "${RED}\tError: git clone failed\n${NORMAL}"
    exit 1
  }
  
  printf "${BLUE}Linking config files into home directory...\n${NORMAL}"
  if [ -e ~/.inputrc ]; then
    printf "\tBacking up .inputrc\n"
    mv ~/.inputrc ~/.inputrc.bak
  fi
  if [ -e ~/.oh-my-zsh ]; then
    printf "\tBacking up .oh-my-zsh\n"
    rm -rf ~/.oh-my-zsh.bak
    mv ~/.oh-my-zsh ~/.oh-my-zsh.bak
  fi
  if [ -e ~/.profile ]; then
    printf "\tBacking up .profile\n"
    mv ~/.profile ~/.profile.bak
  fi
  if [ -e ~/.zprofile ]; then
    printf "\tBacking up .zprofile\n"
    mv ~/.zprofile ~/.zprofile.bak
  fi
  if [ -e ~/.zshrc ]; then
    printf "\tBacking up .zshrc\n"
    mv ~/.zshrc ~/.zshrc.bak
  fi
  printf "${GREEN}\tLinking .inputrc\n${NORMAL}"
  ln -sf "$ENVGIT/dot_files/inputrc" ~/.inputrc
  printf "${GREEN}\tLinking .oh-my-zsh\n${NORMAL}"
  ln -sf "$ENVGIT/dot_files/oh-my-zsh" ~/.oh-my-zsh
  printf "${GREEN}\tLinking .profile\n${NORMAL}"
  ln -sf "$ENVGIT/dot_files/profile" ~/.profile
  printf "${GREEN}\tLinking .zprofile\n${NORMAL}"
  ln -sf "$ENVGIT/dot_files/profile" ~/.zprofile
  printf "${GREEN}\tLinking .zshrc\n${NORMAL}"
  ln -sf "$ENVGIT/dot_files/zshrc" ~/.zshrc
  
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
  env zsh -l
}

main