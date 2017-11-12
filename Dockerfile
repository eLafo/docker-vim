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

# GENERAL DEVELOPMENT LIBRARIES AND TOOLS #########
RUN apt-get update &&\
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections && apt-get install -y -qq --no-install-recommends\
      vim\
      git\
      ruby\
      silversearcher-ag\
      exuberant-ctags\
      locales

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


USER root
RUN apt-get install -y -qq --no-install-recommends \
      curl\
			apt-transport-https \
			ca-certificates \
			curl \
      gnupg2 \
      software-properties-common

RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

RUN apt-get update
RUN apt-get install -y -qq --no-install-recommends docker-ce

RUN usermod -aG docker $USER_NAME
#RUN curl -O https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/docker-ce_17.09.0~ce-0~ubuntu_amd64.deb
#RUN dpkg -i docker-ce_17.09.0~ce-0~ubuntu_amd64.deb
USER $USER_NAME
WORKDIR $WORKSPACE_PATH
ENTRYPOINT vim
