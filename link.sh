

if [ ! -n "$ENVGIT" ]; then
  exit 1
fi

abstract_link() {
  SRC_PREFIX="$1"
  DEST_PREFIX="$2"
  FILE="$3"
  SRC="${SRC_PREFIX}${FILE}"
  DEST="${DEST_PREFIX}${FILE}"
  if [ -L ~/"${DEST}" ]; then
    # file is a link; don't bother backing up
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
  ln -sf "${ENVGIT}/${SRC}" ~/"${DEST}"
}

link_dot_file() {
  abstract_link "dot_files/" "." "$1"
}

link_home_dir() {
  abstract_link "home_dirs/" "" "$1"
}

link_ssh_file() {
  abstract_link "ssh/" ".ssh/" "$1"
}

link_launch_agent() {
  abstract_link "LaunchAgents/" "Library/LaunchAgents/" "$1"
}

if [ ! -n "$ENVGIT" ]; then
  ENVGIT=~/.env.git
fi

printf "${BLUE}Linking environment components into home directory...\n${NORMAL}"
link_home_dir bin
link_dot_file gitconfig
link_dot_file gitignore_global
link_dot_file inputrc
link_dot_file oh-my-zsh
link_dot_file profile
link_dot_file zprofile
link_dot_file zshrc
link_ssh_file authorized_keys
link_ssh_file config
ls LaunchAgents | while read file
do
  link_launch_agent "$file"
  launchctl load ~/Library/LaunchAgents/"$file"
done
