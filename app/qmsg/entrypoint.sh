#!/bin/bash

# 设置时区，默认为 UTC+8
TZ=${TZ:-UTC+8}
export TZ

# 将 Docker 内部 IP 地址提供给进程使用
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# 切换到工作目录
cd /home/container || exit 1

# 函数：检查引号
check_quotes() {
    local input="$1"
    if [ "${input:0:1}" != '"' ] ; then
        if [ "${input:0:1}" != '[' ] ; then
            input="[\"$input\"]"
        fi
    else
        input="[$input]"
    fi
    echo $input
}

# 如果未设置自动更新或者设置为 1，则更新
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then

    # 获取最新版本号
    VERSION=$(curl -sSL https://api.github.com/repos/1244453393/QmsgNtClient-NapCatQQ/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/')

    # 检查是否成功获取版本号
    if [ -z "$VERSION" ]; then
        echo "无法获取最新版本号"
        exit 1
    fi

    # 获取架构信息
    ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
    
    # 下载文件，设置超时为1分钟
    DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/1244453393/QmsgNtClient-NapCatQQ/releases/download/${VERSION}/QmsgNtClient-NapCatQQ_${ARCH}.zip"
    curl -s --max-time 60 -L $DOWNLOAD_URL -o QmsgNtClient-NapCatQQ_${ARCH}.zip

    # 检查文件是否存在并解压文件
    if [ -f QmsgNtClient-NapCatQQ_${ARCH}.zip ]; then
        # 检查zip文件是否有效
        if unzip -t QmsgNtClient-NapCatQQ_${ARCH}.zip > /dev/null 2>&1; then
            unzip -o QmsgNtClient-NapCatQQ_${ARCH}.zip
            # 删除不需要的文件
            rm -f napcat.bat
            rm -f napcat.ps1
            rm -f napcat-log.ps1
            rm -f napcat-utf8.bat
            rm -f napcat-utf8.ps1
            rm -f README.md
        else
            echo "下载的文件无效，无法解压。"
            rm -f QmsgNtClient-NapCatQQ_${ARCH}.zip
        fi
    else
        echo "QmsgNtClient-NapCatQQ_${ARCH}.zip 不存在"
    fi

else
    echo "自动更新未开启。直接启动服务器"
fi

# 设置 WebUI 配置
cat <<EOF > config/webui.json
{
    "port": $SERVER_PORT,
    "token": "$WEBUI_TOKEN",
    "loginRate": 3
}
EOF
# 设置配置文件路径
if [ -z "$ACCOUNT" ]; then
    CONFIG_PATH=config/onebot11.json
else
    CONFIG_PATH=config/onebot11_$ACCOUNT.json
fi

# 计算端口
((HTTP_PORT = SERVER_PORT + 1))
((WS_PORT = SERVER_PORT + 2))

# 输出配置路径
echo "正在设置$CONFIG_PATH"

# 设置默认值
: ${WEBUI_TOKEN:=''}
: ${HTTP_PORT:=3000}
: ${HTTP_URLS:='[]'}
: ${WS_PORT:=3001}
: ${HTTP_ENABLE:='false'}
: ${HTTP_POST_ENABLE:='false'}
: ${WS_ENABLE:='false'}
: ${WSR_ENABLE:='false'}
: ${WS_URLS:='[]'}
: ${HEART_INTERVAL:=60000}
: ${TOKEN:=''}
: ${F2U_ENABLE:='false'}
: ${DEBUG_ENABLE:='false'}
: ${LOG_ENABLE:='false'}
: ${RSM_ENABLE:='false'}
: ${MESSAGE_POST_FORMAT:='array'}
: ${HTTP_HOST:=''}
: ${WS_HOST:=''}
: ${HTTP_HEART_ENABLE:='false'}
: ${MUSIC_SIGN_URL:=''}
: ${HTTP_SECRET:=''}
: ${QMSG_KEY:=''}
: ${QMSG_WEBURL:='https://qmsg.zendee.cn/'}

# 检查引号
HTTP_URLS=$(check_quotes "$HTTP_URLS")
WS_URLS=$(check_quotes "$WS_URLS")

# 写入配置文件
cat <<EOF > $CONFIG_PATH
{
    "qmsg": {
        "qmsgKey": "$QMSG_KEY",
        "qmsgWebUrl": "$QMSG_WEBURL"
    },
    "http": {
      "enable": ${HTTP_ENABLE},
      "host": "$HTTP_HOST",
      "port": ${HTTP_PORT},
      "secret": "$HTTP_SECRET",
      "enableHeart": ${HTTP_HEART_ENABLE},
      "enablePost": ${HTTP_POST_ENABLE},
      "postUrls": $HTTP_URLS
    },
    "ws": {
      "enable": ${WS_ENABLE},
      "host": "${WS_HOST}",
      "port": ${WS_PORT}
    },
    "reverseWs": {
      "enable": ${WSR_ENABLE},
      "urls": $WS_URLS
    },
    "debug": ${DEBUG_ENABLE},
    "heartInterval": ${HEART_INTERVAL},
    "messagePostFormat": "$MESSAGE_POST_FORMAT",
    "enableLocalFile2Url": ${F2U_ENABLE},
    "musicSignUrl": "$MUSIC_SIGN_URL",
    "reportSelfMessage": ${RSM_ENABLE},
    "token": "$TOKEN"
}
EOF

# 安装 napcat
if [ ! -f "napcat.mjs" ]; then
    ARCH=$(arch | sed 's/aarch64/arm64/' | sed 's/x86_64/amd64/')
    unzip -q QmsgNtClient-NapCatQQ_${ARCH}.zip
fi

chmod +x ./napcat.sh
export FFMPEG_PATH=/usr/bin/ffmpeg

# 替换启动变量
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# 运行服务器
eval "${MODIFIED_STARTUP}"
