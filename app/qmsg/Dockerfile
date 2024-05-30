FROM --platform=$TARGETOS/$TARGETARCH node:20-bookworm-slim

LABEL author="Ú˜“œ√Œ" maintainer="aopkcn@qq.com"

ENV DEBIAN_FRONTEND=noninteractive
COPY sources.list /etc/apt/sources.list

RUN  useradd -m -d /home/container -s /bin/bash container \     
     && apt update \
            && apt -y install libnss3 libnotify4 libsecret-1-0 libgbm1 libasound2 fonts-wqy-zenhei gnutls-bin libglib2.0-dev libdbus-1-3 libgtk-3-0 libxss1 libxtst6 libatspi2.0-0 libx11-xcb1 ffmpeg unzip openbox xorg dbus-user-session xvfb supervisor xdg-utils git fluxbox curl iproute2 tini tzdata \
            && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
            && apt autoremove -y \
            && apt clean \
            && rm -rf /var/lib/apt/lists/* 
RUN curl -o /root/linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240428_$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)_01.deb && \
    dpkg -i /root/linuxqq.deb && apt-get -f install -y && rm /root/linuxqq.deb

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

STOPSIGNAL SIGINT

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]