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

# install basic dev packages
sudo apt update && sudo apt install -y git wget fasd fzf nodejs npm python3 python3-pip ripgrep

# install oh-my-zsh
ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d $ZSH_DIR ]; then
    sudo rm -rf $ZSH_DIR
fi
sudo apt install -y zsh && chsh -s /usr/bin/zsh $USER
git clone https://github.com/ohmyzsh/ohmyzsh.git $ZSH_DIR
sudo cp .zshrc $HOME

# install homebrew
sudo apt-get install build-essential
export HOMEBREW_NO_INSTALL_FROM_API=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>$HOME/.zshrc

# install starship
sudo curl -sS https://starship.rs/install.sh | sudo sh
starship preset tokyo-night -o ~/.config/starship.toml

# build nvim
NVIM_DIR="$HOME/neovim"
NVIM_CONF_DIR="$HOME/.config/nvim"
sudo apt install -y ninja-build gettext cmake unzip curl
if [ ! -d $NVIM_DIR ]; then
    git clone https://github.com/neovim/neovim $NVIM_DIR
fi
cd $NVIM_DIR && sudo make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install
if [ -d $NVIM_CONF_DIR ]; then
    sudo rm -rf $NVIM_CONF_DIR
fi
git clone -b feat/nvchad https://github.com/xieping5555/neovim-config.git $NVIM_CONF_DIR
cd -

# build tmux and install tpm
sudo apt install -y libevent-dev ncurses-dev build-essential bison pkg-config
TMUX_DIR=$HOME/tmux
if [ -d $TMUX_DIR ]; then
    sudo rm -rf $TMUX_DIR
fi
git clone https://github.com/tmux/tmux.git $TMUX_DIR
cd $TMUX_DIR
sh autogen.sh
./configure
make && sudo make install
cd -
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d $TPM_DIR ]; then
    sudo rm -rf $TPM_DIR
fi
git clone https://github.com/tmux-plugins/tpm $TPM_DIR
sudo cp .tmux.conf $HOME
$TPM_DIR/bin/install_plugins

# install mcfly
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git --force cantino/mcfly --force

# install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# install golang
GOVERSION="go1.19.5"
GO_DIR="$HOME/$GOVERSION"
if [ -d $GO_DIR ]; then
    sudo rm -rf $GO_DIR
fi
wget -P $HOME https://dl.google.com/go/$GOVERSION.linux-amd64.tar.gz
sudo mkdir $GO_DIR && sudo tar -zxvf $HOME/$GOVERSION.linux-amd64.tar.gz -C $GO_DIR

zsh
