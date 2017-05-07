FROM frolvlad/alpine-oraclejdk8:slim

ARG SBT_VERSION="0.13.15"
ARG SCALA_VERSION="2.12.2"
ARG SCALA_HOME=/usr/share/scala

RUN apk add --no-cache --virtual=build-dependencies wget curl ca-certificates && \
    apk add --no-cache bash && \
    cd "/tmp" && \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    apk del build-dependencies && \
    rm -rf "/tmp/"*
RUN apk add --no-cache --virtual=build-dependencies curl && \
    curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    chmod 0755 /usr/local/bin/sbt && \
    apk del build-dependencies && \
    sbt
RUN apk add --no-cache --virtual=build-dependencies curl musl-dev gcc python3-dev python2-dev && \
    apk add --no-cache git neovim python3 python2 && \
    python2 -m ensurepip && \
    pip2 install --upgrade pip setuptools neovim websocket-client sexpdata && \
    python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools neovim && \
    mkdir -p ~/.config/nvim/autoload && \
    git clone https://github.com/Farga83/dotfiles.git dotfiles && \
    ln -s /dotfiles/init.vim ~/.config/nvim/init.vim && \
    ln -s /dotfiles/.bash_profile ~/.bash_profile && \
    curl -fLo ~/.config/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    apk del build-dependencies
WORKDIR /src
CMD /bin/bash -lc /usr/local/bin/sbt
