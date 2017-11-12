FROM debian:jessie
MAINTAINER eLafo

# DEVELOPMENT ENVIRONMENT CONFIGURATION #####
ENV WORKSPACE_PATH=/workspace

# USER CREATION #########
ENV USER_NAME=dev
ENV USER_HOME=/home/$USER_NAME

ENV PATH $USER_HOME:$PATH

# USER'S WORKSPACE
RUN mkdir $WORKSPACE_PATH
RUN adduser --disabled-password --gecos "" $USER_NAME
RUN chown -R $USER_NAME:$USER_NAME $WORKSPACE_PATH

# Libraries
RUN apt-get update &&\
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections && apt-get install -y -qq --no-install-recommends\
      vim\
      git\
      ruby\
      silversearcher-ag\
      exuberant-ctags\
      locales\
# bash-dot-files requirements
      bash-completion\
# Docker requirements
			apt-transport-https \
			ca-certificates \
			curl \
      gnupg2 \
      software-properties-common

# Installs docker
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - &&\
    apt-key fingerprint 0EBFCD88 &&\ 
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable" &&\
    apt-get update &&\
    apt-get install -y -qq --no-install-recommends docker-ce

RUN usermod -aG docker $USER_NAME

# Installs docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose &&\
    chmod +x /usr/local/bin/docker-compose

# Install Homesick, through which dotfiles configurations will be installed
RUN gem install homesick --no-rdoc --no-ri

# Setting locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&\
    sed -i -e 's/# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
    
RUN locale-gen en_US.UTF-8 es_ES.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Config TERM
ENV TERM=screen-256color

# Dotfiles
USER $USER_NAME

RUN homesick clone https://github.com/eLafo/vim-dot-files.git &&\
    homesick symlink vim-dot-files &&\
    exec vim -c ":PluginInstall" -c "qall"

RUN homesick clone eLafo/bash-dot-files &&\
    homesick symlink --force=true bash-dot-files

VOLUME $WORKSPACE_PATH

WORKDIR $WORKSPACE_PATH

ENTRYPOINT vim
