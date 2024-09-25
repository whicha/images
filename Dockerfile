# >> stage0 >>
FROM ubuntu:22.04 AS installer

ARG CURL_VERSION=8.9.1
ADD https://curl.se/download/curl-$CURL_VERSION.zip /

RUN <<EOF
apt-get update && apt-get install -y unzip 
mkdir -p /curl
unzip /curl-$CURL_VERSION.zip -d /curl
EOF
# << stage0 <<

# >> stage1 >>
FROM ubuntu:22.04

ARG USERNAME=containeruser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

WORKDIR /home/$USERNAME

# git installation
RUN apt-get update && apt-get install -y \
    gnutls-bin \
    software-properties-common \
    && add-apt-repository ppa:git-core/ppa \
    && apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/* 

# curl installation: https://stackoverflow.com/a/75867650/26612416
RUN apt-get update && apt-get install -y \
    libssl-dev \
    autoconf \
    libtool \
    unzip \
    make \
    && rm -rf /var/lib/apt/lists/*

ARG CURL_VERSION=8.9.1

COPY --from=installer /curl/curl-$CURL_VERSION /curl

RUN cd /curl \
    && ./buildconf \
    && ./configure --with-ssl \
    && make \
    && make install \
    && cp /usr/local/bin/curl /usr/bin/curl \
    && ldconfig \
    && cd .. \
    && rm -rf curl-$CURL_VERSION \
    && rm -rf /usr/local/bin/curl 

# useful tools
RUN apt-get update && apt-get install -y \
    vim \
    tmux \
    tree \
    bat \
    fd-find \
    ripgrep \
    wget \
    && rm -rf /var/lib/apt/lists/* 

# Python installation
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv

ENV HOME="/home/${USERNAME}"
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

RUN latest_python_version=$(pyenv install --list | grep --extended-regexp "^\s*[0-9][0-9.]*[0-9]\s*$" | tail -1 | tr -d '[:space:]') \
    && pyenv install $latest_python_version \
    && pyenv global $latest_python_version 

# zsh installation
USER root

RUN apt-get update && apt-get install -y \
    zsh \
    && rm -rf /var/lib/apt/lists/* 

USER $USERNAME

RUN git config --global http.sslVerify false \
    && git config --global http.postBuffer 1048576000 \
    && git config --global core.compression 0 \
    && git clone https://github.com/ohmyzsh/ohmyzsh.git .oh-my-zsh \
    && git clone https://github.com/zsh-users/zsh-autosuggestions .oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git .oh-my-zsh/custom/plugins/zsh-autocomplete \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template .zshrc 

# zoxide installation
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

COPY --chown=$USER_UID:$USER_GID . .

CMD ["/usr/bin/zsh"]
