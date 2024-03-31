#! /bin/bash

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
sudo apt update && sudo apt install -y git wget fasd tmux fzf nodejs npm python3 python3-pip

# install oh-my-zsh
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CONF_PATH="$HOME/.zshrc"
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
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>$ZSH_CONF_PATH
source $ZSH_CONF_PATH

# install starship
brew install starship
starship preset tokyo-night -o ~/.config/starship.toml
echo 'eval "$(starship init zsh)"' >>$ZSH_CONF_PATH
source $ZSH_CONF_PATH

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
git clone -b feat/lazy https://github.com/xieping5555/neovim-config.git $NVIM_CONF_DIR
cd -

# install mcfly
brew install mcfly
echo 'eval "$(mcfly init zsh)"' >>$ZSH_CONF_PATH
source $ZSH_CONF_PATH

# install tpm
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d $TPM_DIR ]; then
    sudo rm -rf $TPM_DIR
fi
git clone https://github.com/tmux-plugins/tpm $TPM_DIR
sudo cp .tmux.conf $HOME
source $TPM_DIR/bin/install_plugins

# install lazygit
brew install jesseduffield/lazygit/lazygit && brew install lazygit

# install golang
GOVERSION="go1.19.5"
GO_DIR="$HOME/$GOVERSION"
if [ -d $GO_DIR ]; then
    sudo rm -rf $GO_DIR
fi
wget -P $HOME https://dl.google.com/go/$GOVERSION.linux-amd64.tar.gz
sudo mkdir $GO_DIR && sudo tar -zxvf $HOME/$GOVERSION.linux-amd64.tar.gz -C $GO_DIR
