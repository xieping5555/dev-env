#!/bin/bash

which sudo >/dev/null 2>&1
if [ $? != 0 ]; then
    apt update
    apt install -y sudo
fi

set -ex

# replace hosts for github domains
sudo sh -c 'sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts'
sudo /etc/init.d/unscd restart

# install oh-my-zsh
ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d $ZSH_DIR ]; then
    sudo rm -rf $ZSH_DIR
fi
sudo apt install -y zsh && chsh -s /usr/bin/zsh $USER
git clone https://github.com/ohmyzsh/ohmyzsh.git $ZSH_DIR
sudo cp .zshrc $HOME
zsh
