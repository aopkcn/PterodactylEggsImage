FROM        --platform=$TARGETOS/$TARGETARCH ubuntu:jammy

LABEL author="蝼蚁梦" maintainer="aopkcn@qq.com"
LABEL org.opencontainers.image.source="https://github.com/aopkcn/PterodactylEggsImage"
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \    
    && apt update \
	&& apt upgrade -y \
	&& apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq \
	&& apt autoremove -y \
    && apt clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*