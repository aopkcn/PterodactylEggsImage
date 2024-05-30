FROM --platform=$TARGETOS/$TARGETARCH ubuntu:22.04

LABEL author="蝼蚁梦" maintainer="aopkcn@qq.com"

ENV DEBIAN_FRONTEND=noninteractive

# 添加容器用户，添加 i386 架构支持，更新和安装必要的软件包，设置时区和语言环境
RUN useradd -m -d /home/container -s /bin/bash container \
    && dpkg --add-architecture i386 \
    && apt update \
    && apt upgrade -y \
    && apt install -y \
       libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 \
       gcc g++ libgcc1 libc++-dev gdb libc6 curl tar iproute2 net-tools libatomic1 libsdl1.2debian libsdl2-2.0-0 \
       libfontconfig locales libcurl3-gnutls libpulse-dev libpulse0 libnss-wrapper gettext tini tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && update-locale lang=en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend noninteractive locales

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

# 准备 NSS Wrapper 以确保 Valheim 需要有效的 UID
ENV NSS_WRAPPER_PASSWD=/tmp/passwd \
    NSS_WRAPPER_GROUP=/tmp/group

RUN touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
    && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
    && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}

ADD passwd.template /passwd.template

# 复制并设置 entrypoint 脚本
STOPSIGNAL SIGINT

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
