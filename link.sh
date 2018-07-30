#!/bin/sh

link_dot_file() {
  FILE="$1"
  if [ -e ~/."${FILE}" ]; then
    printf "\tBacking up .${FILE}\n"
    if [ -d ~/."${FILE}.bak" ]; then
      rm -rf ~/."${FILE}.bak"
    fi
    mv ~/."${FILE}" ~/."${FILE}.bak"
  fi
  printf "${GREEN}\tLinking .${FILE}\n${NORMAL}"
  ln -sf "$ENVGIT/dot_files/${FILE}" ~/."${FILE}"
}

if [ ! -n "$ENVGIT" ]; then
  ENVGIT=~/.env.git
fi

printf "${BLUE}Linking config files into home directory...\n${NORMAL}"
link_dot_file gitconfig
link_dot_file gitignore_global
link_dot_file inputrc
link_dot_file oh-my-zsh
link_dot_file profile
link_dot_file zprofile
link_dot_file zshrc
