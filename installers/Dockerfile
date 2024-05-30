FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="Ú˜“œ√Œ" maintainer="aopkcn@qq.com"
LABEL org.opencontainers.image.source="https://github.com/aopkcn/PterodactylEggsImage"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y \
    && apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq wget tzdata locales \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* 

RUN if [ "$(uname -m)" = "x86_64" ]; then \
        dpkg --add-architecture i386 && \
        apt update && \
        apt -y install lib32gcc-s1 libsdl2-2.0-0:i386; \
    fi
