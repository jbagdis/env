#!/bin/sh

source functions.sh

main() {
    printf "${BOLD}Updating Shell Environment.\n${NORMAL}"
    check_existing_env
	update_env_git
	update_links
	remove_memoized_profile
	update_powerlevel10k
	set_shell_to_zsh
    printf "${BOLD}Shell Environment successfully installed.\n${NORMAL}"
    printf "${BLUE}Memoizing new profile...\n${NORMAL}"
    env zsh -l
}

check_existing_env() {
    printf "${BLUE}Checking for previously-installed environment...\n${NORMAL}"
    if [ -d "${ENVGIT}" ]; then
      printf "${GREEN}\tFound at '${ENVGIT}'.\n${NORMAL}"
    else
      printf "${YELLOW}\tYou do not have an environment installed.\n${NORMAL}"
      printf "\tYou'll need to install one first before you can update.\n"
      exit 1
    fi
}

update_env_git() {
    # update the env git repo
    pushd "${ENVGIT}"
    git pull
    popd
}

update_links() {
    # re-link all files from the env git repo into the home directory
    source "${ENVGIT}/link.sh"
}

remove_memoized_profile() {
    # remove memoized profile so it will be regenerated
    if [ -e ~/.profile.memoized ]; then
      printf "${BLUE}Resetting memoized profile...\n${NORMAL}"
      rm ~/.profile.memoized
    fi
}

update_powerlevel10k() {
    # Pull or clone the PowerLevel10k ZSH theme
    if [ -d "${ENVGIT}/dotfiles/oh-my-zsh/custom/themes/powerlevel10k" ]; then
  	  pushd "${ENVGIT}/dotfiles/oh-my-zsh/custom/themes/powerlevel10k"
  	  git pull
  	  popd
    else
  	  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ENVGIT}/dotfiles/oh-my-zsh/custom/themes/powerlevel10k"
    fi
}

init_colors
init_variables
set -eou pipefail
main
