#!/bin/sh
#
# Adapted from https://github.com/robbyrussell/oh-my-zsh.git
#

source functions.sh

check_prereqs() {
  printf "${BLUE}Checking prerequisites...\n${NORMAL}"
  command -v curl >/dev/null 2>&1 && printf "${GREEN}\t'curl' found.\n${NORMAL}" || (printf "${RED}\t'curl' not found.\n${NORMAL}" && exit 1)
  command -v git >/dev/null 2>&1 && printf "${GREEN}\t'git' found.\n${NORMAL}" || (printf "${RED}\t'git' not found.\n${NORMAL}" && exit 1)
  command -v zsh >/dev/null 2>&1 && printf "${GREEN}\t'zsh' found.\n${NORMAL}" || (printf "${RED}\t'zsh' not found.\n${NORMAL}" && exit 1) 
}

check_existing_env() {
  printf "${BLUE}Checking for previously-installed environment...\n${NORMAL}"
  if [ ! -n "${ENVGIT}" ]; then
    ENVGIT=~/.env.git
  fi
  if [ -d "${ENVGIT}" ]; then
    printf "${YELLOW}\tYou already have an environment installed.\n${NORMAL}"
    printf "\tYou'll need to remove ${ENVGIT} if you want to re-install.\n"
    exit 1
  else
    printf "${GREEN}\tNone found.\n${NORMAL}"
  fi
}

git_setup() {
  env git clone --progress https://github.com/jbagdis/env.git "${ENVGIT}"
  pushd "${ENVGIT}"
  env git submodule init
  env git submodule update
  popd
}

clone_env_git() {
  # Prevent the cloned repository from having insecure permissions.
  #  Failing to do so causes compinit() calls to fail
  #  with "command not found: compdef" errors
  #  for users with insecure umasks
  #  (e.g., "002", allowing group writability).
  # Note that this will be ignored under Cygwin by default,
  #  as Windows ACLs take precedence over umasks
  #  except for filesystems mounted with option "noacl".
  umask g-w,o-w
  
  printf "${BLUE}Cloning Environment Repository...\n${NORMAL}"
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "${OSTYPE}" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "${RED}\tError: Windows/MSYS Git is not supported on Cygwin${NORMAL}"
      echo "\tMake sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  git_setup 2>&1 | sed 's/^/\'$'\t/' || {
    printf "${RED}\tError: git clone failed\n${NORMAL}"
    exit 1
  }
}

setup_ssh_sockets() {
  # Ensure ~/.ssh/sockets directory exits
  mkdir -p ~/.ssh/sockets
}

setup_powerlevel_10k() {
  # Clone the PowerLevel10k ZSH theme
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ENVGIT}"/dotfiles/oh-my-zsh/custom/themes/powerlevel10k  
}

main() {
  printf "${BOLD}Installing Shell Environment.\n${NORMAL}"
  check_prereqs
  check_existing_env
  clone_env_git
  create_or_update_links
  setup_ssh_sockets
  setup_powerlevel_10k
  set_shell_to_zsh
  printf "${BOLD}Shell Environment successfully installed.\n${NORMAL}" 
  printf "${BLUE}Memoizing new profile...\n${NORMAL}"
  env zsh -l
}

init_colors
init_variables
set -eou pipefail
main
