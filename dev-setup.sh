#! /bin/bash

which sudo >/dev/null 2>&1
if [ $? != 0 ]; then
    apt update
    apt install -y sudo
fi

set -ex

# install basic dev packages
sudo apt update && sudo apt install -y git wget fasd tmux fzf nodejs npm python3 python3-pip

# build nvim
NVIM_DIR="$HOME/neovim"
NVIM_CONFDIR="$HOME/.config/nvim"
sudo apt install -y ninja-build gettext cmake unzip curl
if [ ! -d $NVIM_DIR ]; then
    git clone https://github.com/neovim/neovim $NVIM_DIR
fi
cd $NVIM_DIR && sudo make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install
if [ -d $NVIM_CONF_DIR ]; then
    sudo rm -rf $NVIM_CONF_DIR
fi
git clone -b feat/lazy https://github.com/xieping5555/neovim-config.git $NVIM_CONF_DIR
cd -

# install mcfly
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly

# install tpm
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d $TPM_DIR ]; then
    sudo rm -rf $TPM_DIR
fi
git clone https://github.com/tmux-plugins/tpm $TPM_DIR
sudo cp .tmux.conf $HOME

# install lazygit
LAZYGIT_DIR="$HOME/lazygit"
if [ -d "$LAZYGIT_DIR" ]; then
    sudo rm -rf "$LAZYGIT_DIR"
fi
sudo mkdir -p $LAZYGIT_DIR
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo $LAZYGIT_DIR/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf $LAZYGIT_DIR/lazygit.tar.gz -C $LAZYGIT_DIR
sudo install $LAZYGIT_DIR/lazygit /usr/local/bin

# install golang
GOVERSION="go1.19.5"
GO_DIR="$HOME/$GOVERSION"
if [ -d $GO_DIR ]; then
    sudo rm -rf $GO_DIR
fi
wget -P $HOME https://dl.google.com/go/$GOVERSION.linux-amd64.tar.gz
sudo mkdir $GO_DIR && tar -zxvf $HOME/$GOVERSION.linux-amd64.tar.gz -C $GO_DIR

# install oh-my-zsh
ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d $ZSH_DIR ]; then
    sudo rm -rf $ZSH_DIR
fi
sudo apt install -y zsh && chsh -s /usr/bin/zsh $USER
git clone https://github.com/ohmyzsh/ohmyzsh.git $ZSH_DIR
sudo cp .zshrc $HOME
zsh
