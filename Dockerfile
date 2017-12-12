FROM ruby:2.3.3-slim
MAINTAINER eLafo

# DEVELOPMENT ENVIRONMENT CONFIGURATION #####
ENV WORKSPACE_PATH=/workspace

# RUBY
ENV GEM_HOME /gems
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_BIN $BUNDLE_PATH/bin
ENV BUNDLE_APP_CONFIG $APP_HOME/.bundle
RUN mkdir $GEM_HOME

# NODE
ENV NODE_MODULES_PATH node_modules
ENV NODE_MODULES_BIN_PATH $NODE_MODULES_PATH/.bin

# USER CREATION #########
ENV USER_NAME=dev
ENV USER_HOME=/home/$USER_NAME
ENV BIN_PATH=$USER_HOME/bin

ENV PATH $USER_HOME:$BUNDLE_BIN:$PATH:$NODE_MODULES_BIN_PATH
ENV PATH $BIN_PATH:$USER_HOME:$BUNDLE_BIN:$PATH

# USER'S WORKSPACE
RUN adduser --disabled-password --gecos "" $USER_NAME
RUN mkdir -p $WORKSPACE_PATH 
RUN mkdir -p $BIN_PATH
RUN chown -R $USER_NAME:$USER_NAME $WORKSPACE_PATH &&\
    chown -R $USER_NAME:$USER_NAME $BIN_PATH

# Libraries
RUN apt-get update &&\
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections && apt-get install -y -qq --no-install-recommends\
      vim\
      git\
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

# Installs node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -q -y nodejs

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

RUN homesick clone eLafo/git-dot-files &&\
    homesick symlink --force=true git-dot-files

VOLUME $WORKSPACE_PATH

WORKDIR $WORKSPACE_PATH

CMD vim
