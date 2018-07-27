#!/bin/sh

set -e

get_script_dir() {
     SOURCE="${BASH_SOURCE[0]}"
     # While $SOURCE is a symlink, resolve it
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          # If $SOURCE was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
     echo "$DIR"
}

DIR=$(get_script_dir)
ln -sf "$DIR/dot_files/profile" ~/.profile
ln -sf "$DIR/dot_files/profile" ~/.zprofile
ln -sf "$DIR/dot_files/inputrc" ~/.inputrc

#echo "Installing Shell Environment."
#echo "Checking prerequisites..."
#which curl >/dev/null 2>&1 && echo "\t'curl' found" || (echo "\t'curl' not found." && exit 1)
#which git >/dev/null 2>&1 && echo "\t'git' found" || (echo "\t'git' not found." && exit 1)
#echo "All prerequisites satisfied."

#echo "Installing Oh-My-Zsh"
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

