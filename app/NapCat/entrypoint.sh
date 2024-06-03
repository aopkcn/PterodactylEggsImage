#!/bin/bash

# 设置默认时区为 UTC+8
TZ=${TZ:-UTC+8}
export TZ

# 获取 Docker 内部 IP 地址
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# 切换到工作目录
cd /home/container || exit 1

# 函数：检查引号
check_quotes() {
    local input="$1"
    if [[ "${input:0:1}" != '"' ]]; then
        if [[ "${input:0:1}" != '[' ]]; then
            input="[\"$input\"]"
        fi
    else
        input="[$input]"
    fi
    echo "$input"
}

# 自动更新
if [[ -z ${AUTO_UPDATE} || "${AUTO_UPDATE}" == "1" ]]; then
    # 获取最新版本号
    LATEST_VERSION=$(curl -sSL https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/')

    # 获取本地版本号
    LOCAL_VERSION=$(grep '"version":' /home/container/package.json | sed -E 's/.*"version":\s*"([^"]+)".*/\1/')

    echo "最新版本: $LATEST_VERSION"
    echo "本地版本: $LOCAL_VERSION"

    if [ "$LATEST_VERSION" != "$LOCAL_VERSION" ]; then
        echo "版本不匹配，开始更新..."
        # 获取架构信息
        ARCH=$(dpkg --print-architecture | sed 's/amd64/x64/' | sed 's/arm64/arm64/')
        DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/NapNeko/NapCatQQ/releases/download/${LATEST_VERSION}/NapCat.linux.${ARCH}.zip"

        # 下载并解压文件
        curl -s -X GET -L $DOWNLOAD_URL -o NapCat.linux.${ARCH}.zip
        if [ -f NapCat.linux.${ARCH}.zip ]; then
            unzip -o NapCat.linux.${ARCH}.zip -d /home/container
            mv NapCat.linux.${ARCH}/* /home/container
            rm -f NapCat.linux.${ARCH}.zip
            rm -fR README.md
            rm -fR NapCat.linux.${ARCH}
            echo "更新完成。"
        else
            echo "下载失败: NapCat.linux.${ARCH}.zip 不存在"
        fi
    else
        echo "版本匹配，不需要更新。"
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

# 检查引号
HTTP_URLS=$(check_quotes $HTTP_URLS)
WS_URLS=$(check_quotes $WS_URLS)

# 写入配置文件
cat <<EOF > $CONFIG_PATH
{
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
    echo "napcat.mjs文件不存在亲重新安装！"
fi

# 确保脚本具有执行权限
chmod +x ./napcat.sh

# 设置 FFMPEG 路径
export FFMPEG_PATH=/usr/bin/ffmpeg

# 替换启动变量
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# 运行服务器
eval "${MODIFIED_STARTUP}"
