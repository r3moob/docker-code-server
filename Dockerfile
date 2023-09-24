FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# install runtime dependencies
RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    curl \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo \
    make \
    vim \
    ca-certificates

# install python
RUN \
  echo "**** install c++ dependencies ****" && \
  apt-get install -y \
    python3-minimal

# install C++
RUN \
  echo "**** install c++ dependencies ****" && \
  apt-get install -y \
    build-essential \
    cmake \
    clang \
    ccache

# Installing Node
#SHELL ["/bin/bash", "--login", "-i", "-c"]
#RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
#RUN source /root/.bashrc && nvm install 20
#SHELL ["/bin/bash", "--login", "-c"]

#RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.39.5/install.sh | bash \
#  && . $NVM_DIR/nvm.sh \
#  && nvm install $NODE_VERSION

RUN mkdir -p /usr/local/nvm
#ENV NVM_DIR /root/.nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 20.7.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION"
# add node and npm to the PATH
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin
ENV PATH $NODE_PATH:$PATH
RUN npm -v
RUN node -v

# install code-server
RUN \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1


# clean up
RUN \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
