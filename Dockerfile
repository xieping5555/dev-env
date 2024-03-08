FROM debian

MAINTAINER xieping.ekko "pgsgdsg@gmail.com"

# replace debian sources
# RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

WORKDIR /root
ENV LANG=en_US.UTF-8
ENV TERM=xterm-256color

# intall basic dev pkgs
RUN apt update && apt install -y git wget fasd tmux fzf nodejs npm python3 python3-pip

# build nvim
RUN git clone https://github.com/neovim/neovim
RUN apt install -y ninja-build gettext cmake unzip curl 
RUN cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install
RUN git clone -b feat/lazy https://github.com/xieping5555/neovim-config.git  .config/nvim

# install mcfly
RUN curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly

# install oh-my-zsh
RUN apt install -y zsh && chsh -s /usr/bin/zsh $USER
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ADD .zshrc .

# install tmux
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ADD .tmux.conf .

# install lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
RUN tar xf lazygit.tar.gz lazygit
RUN install lazygit /usr/local/bin

# install golang
ARG GOVERSION="go1.19.5"
RUN wget -P $HOME https://dl.google.com/go/$GOVERSION.linux-amd64.tar.gz
RUN mkdir $GOVERSION && tar -zxvf $GOVERSION.linux-amd64.tar.gz -C $GOVERSION

ENTRYPOINT ["/usr/bin/zsh"]
