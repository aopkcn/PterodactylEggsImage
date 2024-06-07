FROM        --platform=$TARGETOS/$TARGETARCH alpine:latest

LABEL author="蝼蚁梦" maintainer="aopkcn@qq.com"
LABEL org.opencontainers.image.source="https://github.com/aopkcn/PterodactylEggsImage"

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
RUN apk add --update --no-cache ca-certificates curl unzip tar git jq wget