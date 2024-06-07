FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="蝼蚁梦" maintainer="aopkcn@qq.com"
LABEL org.opencontainers.image.source="https://github.com/aopkcn/PterodactylEggsImage"
ENV DEBIAN_FRONTEND=noninteractive

#RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
RUN apt update && apt upgrade -y \
    && apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq wget tzdata locales \
    && update-locale lang=en_US.UTF-8 \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive locales \
    && apt autoremove -y \
    && apt clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

RUN if [ "$(uname -m)" = "x86_64" ]; then \
        dpkg --add-architecture i386 && \
        apt update && \
        apt -y install lib32gcc-s1 libsdl2-2.0-0:i386; \
    fi
