#!/bin/bash
TZ=${TZ:-UTC+8}
export TZ
# 将 Docker 内部 IP 地址提供给进程使用。
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

chech_quotes(){
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

    # 获取架构信息
    ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
    # 下载文件，设置超时为1分钟
    DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/1244453393/QmsgNtClient-NapCatQQ/releases/download/${VERSION}/QmsgNtClient-NapCatQQ_${ARCH}.zip"
    curl -s -X GET -L $DOWNLOAD_URL -o QmsgNtClient-NapCatQQ_${ARCH}.zip

    # 检查文件是否存在并解压文件
    if [ -f QmsgNtClient-NapCatQQ_${ARCH}.zip ]; then
        unzip -o QmsgNtClient-NapCatQQ_${ARCH}.zip
        #mv NapCat.linux.${ARCH}/* /home/container
        # 删除不需要的文件
        #rm -fR NapCat.linux.${ARCH}
        rm -fR napcat.bat
        rm -fR napcat.ps1
        rm -fR napcat-log.ps1
        rm -fR napcat-utf8.bat
        rm -fR napcat-utf8.ps1
        rm -fR README.md
    else
        echo "QmsgNtClient-NapCatQQ_${ARCH}.zip 不存在"
    fi

else
    echo -e "自动更新未开启。直接启动服务器"
fi
CONFIG_PATH=config/onebot11_$ACCOUNT.json
((HTTP_PORT = SERVER_PORT + 1))
((WS_PORT = SERVER_PORT + 2))
# 容器首次启动时执行
if [ ! -f "$CONFIG_PATH" ]; then
    echo "{\"port\": $SERVER_PORT,\"token\": \"$WEBUI_TOKEN\",\"loginRate\": 3}" > config/webui.json

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
    HTTP_URLS=$(chech_quotes $HTTP_URLS)
    WS_URLS=$(chech_quotes $WS_URLS)
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
fi
    # 安装 napcat
if [ ! -f "napcat.mjs" ]; then
    rarch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
    unzip -q QmsgNtClient-NapCatQQ_${ARCH}.zip
    #mv NapCat.linux.${rarch}/* /
fi
chmod +x ./napcat.sh
export FFMPEG_PATH=/usr/bin/ffmpeg

# 替换启动变量
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# 运行服务器
eval ${MODIFIED_STARTUP}
