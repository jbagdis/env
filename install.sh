#!/usr/bin/env bash
#
# Adapted from https://github.com/robbyrussell/oh-my-zsh.git
#

# Variable in printf strings reads more cleanly in some cases
# shellcheck disable=SC2059

set -euo pipefail

get_user() {
  # user account name aliases should be defined here
	echo "${USER/jbagdis/jeff}"
}

init_colors() {
  set +u
  # Use colors, but only if connected to a terminal
  # and only if that terminal supports them.
  if command -v tput >/dev/null 2>&1; then
    num_colors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$num_colors" ] && [ "$num_colors" -ge 8 ]; then
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
  set -u
}

init_variables() {
  # set default values
  set +u
  if [ -z "${ENV_GIT_DIR}" ]; then
    ENV_GIT_DIR=~/.env.git
  fi
  set -u
}

create_directories_if_needed() {
  # Ensure ~/.ssh/sockets directory exits
  mkdir -p ~/.ssh/sockets

  # Ensure ipython configuration directory exists
  mkdir -p ~/.ipython/profile_default
}

create_or_update_links() {
  # (re-)link all files from the env git repo into the home directory
  printf "${BLUE}Linking environment components into home directory...\n${NORMAL}"
  link_home_dir bin ""
  link_dot_file gitconfig ""
  link_dot_file gitconfig.user "_$(get_user)"
  link_dot_file gitignore_global ""
  link_dot_file inputrc ""
  link_dot_file oh-my-zsh ""
  link_dot_file profile ""
  link_dot_file zprofile ""
  link_dot_file zshrc ""
  link_ssh_file authorized_keys "_$(get_user)"
  link_ssh_file config ""
  link_dot_file p10k.zsh "_$(get_user)"
  link_dot_file "ipython/profile_default/ipython_config.py" ""
  link_dot_file "tmux.conf" ""

  # shellcheck disable=SC2012
  ls "${ENV_GIT_DIR}/LaunchAgents" | while read -r file; do
    link_launch_agent "$file" ""
    launchctl load ~/Library/LaunchAgents/"$file" 2>&1 | while read -r line; do
      printf "\t\t${YELLOW}> %s${NORMAL}\n" "$line"
    done
  done
}

set_shell_to_zsh() {
  # If this user's login shell is not already "zsh", attempt to switch.
  printf "${BLUE}Verifying that your shell is zsh...\n${NORMAL}"
  TEST_CURRENT_SHELL=$(expr "${SHELL}" : '.*/\(.*\)')
  if [ "${TEST_CURRENT_SHELL}" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      printf "${GREEN}\tChanging your default shell to zsh.\n${NORMAL}"
      chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
    # Else, suggest the user do so manually.
    else
      printf "${RED}\tCannot change your shell automatically because this system does not have chsh.\n${NORMAL}"
      printf "\tPlease manually change your default shell to zsh.\n"
    fi
  else
    printf "${GREEN}\tYour current shell is already ${TEST_CURRENT_SHELL}\n${NORMAL}"
  fi
}

abstract_link() {
  SRC_PREFIX="$1"
  DEST_PREFIX="$2"
  FILE="$3"
  SRC_SUFFIX="$4"
  SRC="${SRC_PREFIX}${FILE}${SRC_SUFFIX}"
  DEST="${DEST_PREFIX}${FILE}"
  if [ -L ~/"${DEST}" ]; then
    # file is a link; don't bother backing up
    rm ~/"${DEST}"
    true
  else
    if [ -e ~/"${DEST}" ]; then
      printf "\tBacking up ${DEST}\n"
      if [ -d ~/"${DEST}.bak" ]; then
        rm -rf ~/"${DEST}.bak"
      fi
      mv ~/"${DEST}" ~/"${DEST}.bak"
    fi
  fi
  printf "${GREEN}\tLinking ${DEST}\n${NORMAL}"
  ln -sf "${ENV_GIT_DIR}/${SRC}" ~/"${DEST}"
  #echo "ln -sf \"${ENV_GIT_DIR}/${SRC}\" ~/\"${DEST}\""
}

link_dot_file() {
  abstract_link "dot_files/" "." "$1" "$2"
}

link_home_dir() {
  abstract_link "home_dirs/" "" "$1" "$2"
}

link_ssh_file() {
  abstract_link "ssh/" ".ssh/" "$1" "$2"
}

link_launch_agent() {
  abstract_link "LaunchAgents/" "Library/LaunchAgents/" "$1" "$2"
}

install_check_prereqs() {
  printf "${BLUE}Checking prerequisites...\n${NORMAL}"
  (command -v curl >/dev/null 2>&1 && printf "${GREEN}\t'curl' found.\n${NORMAL}") || (printf "${RED}\t'curl' not found.\n${NORMAL}" && exit 1)
  (command -v git >/dev/null 2>&1 && printf "${GREEN}\t'git' found.\n${NORMAL}") || (printf "${RED}\t'git' not found.\n${NORMAL}" && exit 1)
  (command -v zsh >/dev/null 2>&1 && printf "${GREEN}\t'zsh' found.\n${NORMAL}") || (printf "${RED}\t'zsh' not found.\n${NORMAL}" && exit 1)
}

install_check_existing_env() {
  printf "${BLUE}Checking for previously-installed environment...\n${NORMAL}"
  set +u
  if [ -z "${ENV_GIT_DIR}" ]; then
    ENV_GIT_DIR=~/.env.git
  fi
  set -u
  if [ -d "${ENV_GIT_DIR}" ]; then
    printf "${YELLOW}\tYou already have an environment installed.\n${NORMAL}"
    printf "\tYou'll need to remove ${ENV_GIT_DIR} if you want to re-install.\n"
    exit 1
  else
    printf "${GREEN}\tNone found.\n${NORMAL}"
  fi
}

update_check_existing_env() {
  printf "${BLUE}Checking for previously-installed environment...\n${NORMAL}"
  if [ -d "${ENV_GIT_DIR}" ]; then
    printf "${GREEN}\tFound at '${ENV_GIT_DIR}'.\n${NORMAL}"
  else
    printf "${YELLOW}\tYou do not have an environment installed.\n${NORMAL}"
    printf "\tYou'll need to install one first before you can update.\n"
    exit 1
  fi
}

install_env_git_do_clone() {
  env git clone --progress https://github.com/jbagdis/env.git "${ENV_GIT_DIR}" &&
    pushd "${ENV_GIT_DIR}" &&
    git remote set-url --push origin git@github.com:jbagdis/env.git &&
    pushd dot_files &&
    env git clone --progress https://github.com/ohmyzsh/ohmyzsh.git oh-my-zsh &&
    popd &&
    popd
}

install_env_git() {
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
    if git --version | grep msysgit >/dev/null; then
      printf "${RED}\tError: Windows/MSYS Git is not supported on Cygwin${NORMAL}"
      printf "\tMake sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  echo "${YELLOW}vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
  install_env_git_do_clone || {
    printf "${RED}\tError: git clone failed\n${NORMAL}"
    exit 1
  }
  echo "${YELLOW}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NORMAL}"
}

update_env_git() {
  # update the env git repo
  pushd "${ENV_GIT_DIR}"
  if [ "$(git rev-parse --abbrev-ref HEAD)" = "main" ]; then
    git pull
  else
    printf "${YELLOW}\tYou are not on the 'main' branch; skipping 'git pull'.\n${NORMAL}"
  fi
  popd
}

install_or_update_powerlevel_10k() {
  # Pull or clone the PowerLevel10k ZSH theme
  echo "${YELLOW}vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
  if [ -d "${ENV_GIT_DIR}/dot_files/oh-my-zsh/custom/themes/powerlevel10k" ]; then
    pushd "${ENV_GIT_DIR}/dot_files/oh-my-zsh/custom/themes/powerlevel10k"
    git pull
    popd
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ENV_GIT_DIR}/dot_files/oh-my-zsh/custom/themes/powerlevel10k"
  fi
  echo "${YELLOW}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NORMAL}"
}

update_remove_memoized_profile() {
  # remove memoized profile so it will be regenerated
  if [ -e ~/.profile.memoized ]; then
    printf "${BLUE}Resetting memoized profile...\n${NORMAL}"
    rm ~/.profile.memoized
  fi
}

install() {
  init_colors
  init_variables
  printf "${BOLD}Installing Shell Environment.\n${NORMAL}"
  install_check_prereqs
  install_check_existing_env
  install_env_git
  create_directories_if_needed
  create_or_update_links
  install_or_update_powerlevel_10k
  set_shell_to_zsh
  printf "${BOLD}Shell Environment successfully installed.\n${NORMAL}"
  printf "${BLUE}Memoizing new profile...\n${NORMAL}"
  env zsh -l
}

update() {
  init_colors
  init_variables
  printf "${BOLD}Updating Shell Environment.\n${NORMAL}"
  update_check_existing_env
  update_env_git
  create_directories_if_needed
  create_or_update_links
  update_remove_memoized_profile
  install_or_update_powerlevel_10k
  set_shell_to_zsh
  printf "${BOLD}Shell Environment successfully installed.\n${NORMAL}"
  printf "${BLUE}Memoizing new profile... (ignore PowerLevel10k git prompt error.)\n${NORMAL}"
  env zsh -l
}
