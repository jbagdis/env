#!/bin/sh

init_colors() {
    # Use colors, but only if connected to a terminal
	# and only if that terminal supports them.
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
}

init_variables() {
	# set default values
	if [ ! -n "${ENVGIT}" ]; then
	  ENVGIT=~/.env.git
	fi
}

create_or_update_links() {
    # (re-)link all files from the env git repo into the home directory
    source "${ENVGIT}/link.sh"
}

set_shell_to_zsh() {
    # If this user's login shell is not already "zsh", attempt to switch.
    printf "${BLUE}Verifying that your shell is zsh...\n${NORMAL}"
    TEST_CURRENT_SHELL=$(expr "${SHELL}" : '.*/\(.*\)')
    if [ "${TEST_CURRENT_SHELL}" != "zsh" ]; then
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
}
