FROM --platform=$TARGETOS/$TARGETARCH debian:12-slim

LABEL author="蝼蚁梦" maintainer="aopkcn@qq.com"

ENV DEBIAN_FRONTEND=noninteractive
# 安装必要的软件包
RUN  useradd -m -d /home/container -s /bin/bash container \ 

     #&& sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
     && apt update \
            && apt install -y \
            libnss3 \
            libnotify4 \
            libsecret-1-0 \
            libgbm1 \
            libasound2 \
            fonts-wqy-zenhei \
            gnutls-bin \
            libglib2.0-dev \
            libdbus-1-3 \
            libgtk-3-0 \
            libxss1 \
            libxtst6 \
            libatspi2.0-0 \
            libx11-xcb1 \
            ffmpeg \
            unzip \
            curl \
            iproute2 \
            tini \
            tzdata \
            && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
            && apt autoremove -y \
            && apt clean \
            && rm -rf \
            /var/lib/apt/lists/* \
            /tmp/* \
            /var/tmp/*
COPY --chown=container:container entrypoint.sh /entrypoint.sh            
# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.8_240520_${arch}_01.deb && \
    dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb && \
    chmod +x entrypoint.sh

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

STOPSIGNAL SIGINT

ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]