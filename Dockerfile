FROM ubuntu:focal

ENV NVM_DIR /root/.nvm
ENV NVM_VERSION=0.39.1
ENV NODE_VERSION 17

# Install ubuntu basics
RUN export DEBIAN_FRONTEND=noninteractive   \
    && apt-get update                       \
    && apt-get install -yq                  \   
        curl                                \
        git                                 \
        npm                                 \
        wget                                \
    && apt-get clean -yq                    \
    && rm -rf /var/lib/apt/lists/*

# Use bash shell - Needed to use ansi-c quotes
SHELL ["/bin/bash", "-c"]

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use ${NODE_VERSION}

ENV NODE_PATH ${NVM_DIR}/v${NODE_VERSION}/lib/node_modules
ENV PATH      ${NVM_DIR}/v${NODE_VERSION}/bin:$PATH

# Update npm
RUN npm install npm@latest -g

# Some nice-to-haves when using git inside the container
RUN echo $'\n\
parse_git_branch() {\n\
  git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \\(.*\\)/ (\\1)/"\n\
} \n\
export PS1="\u@\h \W\[\\033[32m\\]\\$(parse_git_branch)\\[\\033[00m\\] $ "\n\
if [ -f ~/.git-completion.bash ]; then\n\
  . ~/.git-completion.bash\n\
fi\n\
' >> /root/.bashrc

WORKDIR /root