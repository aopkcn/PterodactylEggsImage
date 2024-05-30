#!/bin/bash
cd /home/container

# 将 Docker 内部 IP 地址提供给进程使用。
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP


# 如果未设置自动更新或者设置为 1，则更新
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then

    # 获取最新版本号
    VERSION=$(curl -sSL https://fastly.jsdelivr.net/gh/1244453393/QmsgNtClient-NapCatQQ@main/package.json | grep '"version":' | sed -E 's/.*"version":\s*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')

    # 获取架构信息
    ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

    # 下载文件，设置超时为1分钟
    DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/1244453393/QmsgNtClient-NapCatQQ/releases/download/v${VERSION}/QmsgNtClient-NapCatQQ_${ARCH}.zip"

    curl --max-time 60 -o QmsgNtClient-NapCatQQ.zip $DOWNLOAD_URL
  
    curl --max-time 60 -o static.zip https://a.aopk.cn:444/static.zip

    # 检查文件是否存在并解压文件
    if [ -f QmsgNtClient-NapCatQQ.zip ]; then
        unzip -o QmsgNtClient-NapCatQQ.zip
        # 删除不需要的文件
        rm -fR QmsgNtClient-NapCatQQ.zip
        rm -fR napcat.bat
        rm -fR napcat.ps1
        rm -fR napcat-log.ps1
        rm -fR napcat-utf8.bat
        rm -fR napcat-utf8.ps1
        rm -fR README.md
    else
        echo "QmsgNtClient-NapCatQQ.zip 不存在"
    fi

    if [ -f static.zip ]; then
        unzip -o static.zip
        rm -fR static.zip
    else
        echo "static.zip 不存在"
    fi
else
    echo -e "自动更新未开启。直接启动服务器"
fi

chmod +x ./napcat.sh
export FFMPEG_PATH=/usr/bin/ffmpeg

# 替换启动变量
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# 运行服务器
eval ${MODIFIED_STARTUP}
