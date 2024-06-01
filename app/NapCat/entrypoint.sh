#!/bin/bash


TZ=${TZ:-UTC}
export TZ
# �� Docker �ڲ� IP ��ַ�ṩ������ʹ�á�
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

# ���δ�����Զ����»�������Ϊ 1�������
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then

    # ��ȡ���°汾��
    VERSION=$(curl -sSL https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/')

    # ��ȡ�ܹ���Ϣ
    ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/)
    # �����ļ������ó�ʱΪ1����
    DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/NapNeko/NapCatQQ/releases/download/${VERSION}/NapCat.linux.${ARCH}.zip"

    curl -s -X GET -L $DOWNLOAD_URL -o NapCat.linux.${ARCH}.zip

    # ����ļ��Ƿ���ڲ���ѹ�ļ�
    if [ -f NapCat.linux.${ARCH}.zip ]; then
        unzip -o NapCat.linux.${ARCH}.zip
        mv NapCat.linux.${ARCH}/* /home/container
        # ɾ������Ҫ���ļ�
        rm -fR NapCat.linux.${ARCH}
    else
        echo "NapCat.linux.${ARCH}.zip ������"
    fi

else
    echo -e "�Զ�����δ������ֱ������������"
fi
CONFIG_PATH=config/onebot11_$ACCOUNT.json
((HTTP_PORT = SERVER_PORT + 1))
((WS_PORT = SERVER_PORT + 2))
# �����״�����ʱִ��
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
    # ��װ napcat
if [ ! -f "napcat.mjs" ]; then
    rarch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/)
    unzip -q NapCat.linux.${rarch}.zip
    mv NapCat.linux.${rarch}/* /
fi
chmod +x ./napcat.sh
export FFMPEG_PATH=/usr/bin/ffmpeg

# �滻��������
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# ���з�����
eval ${MODIFIED_STARTUP}
