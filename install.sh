#!/usr/bin/env bash

taps=(
  # "popcorn-official/popcorn-desktop https://github.com/popcorn-official/popcorn-desktop.git"
)

# See https://sdkman.io/
sdks=(
  # "java 8.0.352-amzn"
  # "sbt 1.8.3"
  # "scala 2.12.18"
)

brews=(
  # Install some stuff before others so we can start settings things up!
  # Software
  firefox
  google-chrome
  vivaldi
  rectangle
  visual-studio-code
  #macfuse
  mas

  # Command line utils
  bash
  git
  python3

  # Software
  #github
  vlc
  caffeine
  #sloth         # https://sveinbjorn.org/sloth
  #soundsource   # https://rogueamoeba.com/soundsource/
  steam
  qbittorrent
  windscribe
  #touch-bar-simulator
  disk-inventory-x
  alt-tab
  audacity
  balenaetcher
  #brave-browser
  gimp
  inkscape
  iterm2
  zoom
  stellarium
  geany
  libreoffice
  #nasas-eyes
  #mari0
  #ntfstool
  plex
  launchpad-manager
  seafile-client
  

  # Command line tools
  python
)

pips=(
  pip
)

gems=(
)

npms=(
)

# Git configs

vscode=(
)

fonts=(
)

######################################## End of app list ########################################
set +e
set -x

function install {
  cmd=$1
  shift
  for pkg in "$@";
  do
    exec="$cmd $pkg"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
      if [[ -n "${CI}" ]]; then
        exit 1
      fi
    fi
  done
}

function brew_install_or_upgrade {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" > /dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install "$1"
  fi
}

if [[ -z "${CI}" ]]; then
  sudo -v # Ask for the administrator password upfront
  # Keep-alive: update existing `sudo` time stamp until script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

if test ! "$(command -v brew)"; then
  echo "Installing Homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
  if [[ -z "${CI}" ]]; then
    echo "Updating Homebrew ..."
    brew update
    brew upgrade
    brew doctor
  fi
fi
export HOMEBREW_NO_AUTO_UPDATE=1

#echo "Installing SDKs ..."
#curl -s "https://get.sdkman.io" | bash
# shellcheck source=/dev/null
#source "$HOME/.sdkman/bin/sdkman-init.sh"
#for sdk in "${sdks[@]}"
#do
#  # shellcheck disable=SC2086
#  sdk install ${sdk}
#done
#sdk current
#echo "Installing NVM ..."
#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

#echo "Installing software ..."
#for tap in "${taps[@]}"
#do
#  # shellcheck disable=SC2086
#  brew tap ${tap}
#done
install 'brew_install_or_upgrade' "${brews[@]}"
brew link --overwrite ruby

echo "Setting up git defaults ..."
#for config in "${git_configs[@]}"
#do
#  git config --global "${config}"
#done

#if [[ -z "${CI}" ]]; then
#  gpg --keyserver hkp://pgp.mit.edu --recv ${gpg_key}
#  echo "Export key to Github"
#  ssh-keygen -t rsa -b 4096 -C ${git_email}
#  pbcopy < ~/.ssh/id_rsa.pub
#  open https://github.com/settings/ssh/new
#fi

#echo "Setting up bash aliases ..."
#echo "
#alias del='mv -t ~/.Trash/'
#alias ls='exa -l'
#alias cat=bat
#" >> ~/.bash_profile
## https://github.com/twolfson/sexy-bash-prompt
#echo "Setting up bash prompt ..."
## shellcheck source=/dev/null
#(cd /tmp && ([[ -d sexy-bash-prompt ]] || git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt) && cd sexy-bash-prompt && make install) && source ~/.bashrc


echo "Installing secondary packages ..."
install 'pip3 install --upgrade' "${pips[@]}"
install 'gem install' "${gems[@]}"
install 'npm install --global --force' "${npms[@]}"
install 'code --install-extension' "${vscode[@]}"

echo "Installing fonts ..."
brew tap homebrew/cask-fonts
install 'brew install' "${fonts[@]}"

echo "Updating packages ..."
pip3 install --upgrade pip setuptools wheel
if [[ -z "${CI}" ]]; then
  m update install all
fi

if [[ -z "${CI}" ]]; then
  echo "Install software from the App Store"
  #mas list
  mas install 682658836 #Garageband
fi

echo "Cleanup"
brew cleanup

echo "Done!"
