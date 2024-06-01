#!/bin/bash
cd /home/container

# �� Docker �ڲ� IP ��ַ�ṩ������ʹ�á�
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP


# ���δ�����Զ����»�������Ϊ 1�������
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then

    # ��ȡ���°汾��
    VERSION=$(curl -sSL https://fastly.jsdelivr.net/gh/1244453393/QmsgNtClient-NapCatQQ@main/package.json | grep '"version":' | sed -E 's/.*"version":\s*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')

    # ��ȡ�ܹ���Ϣ
    ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

    # �����ļ������ó�ʱΪ1����
    DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/1244453393/QmsgNtClient-NapCatQQ/releases/download/v${VERSION}/QmsgNtClient-NapCatQQ_${ARCH}.zip"

    curl --max-time 60 -o QmsgNtClient-NapCatQQ.zip $DOWNLOAD_URL
  
    curl --max-time 60 -o static.zip https://a.aopk.cn:444/static.zip

    # ����ļ��Ƿ���ڲ���ѹ�ļ�
    if [ -f QmsgNtClient-NapCatQQ.zip ]; then
        unzip -o QmsgNtClient-NapCatQQ.zip
        # ɾ������Ҫ���ļ�
        rm -fR QmsgNtClient-NapCatQQ.zip
        rm -fR napcat.bat
        rm -fR napcat.ps1
        rm -fR napcat-log.ps1
        rm -fR napcat-utf8.bat
        rm -fR napcat-utf8.ps1
        rm -fR README.md
    else
        echo "QmsgNtClient-NapCatQQ.zip ������"
    fi

    if [ -f static.zip ]; then
        unzip -o static.zip
        rm -fR static.zip
    else
        echo "static.zip ������"
    fi
else
    echo -e "�Զ�����δ������ֱ������������"
fi

chmod +x ./napcat.sh
export FFMPEG_PATH=/usr/bin/ffmpeg

# �滻��������
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# ���з�����
eval ${MODIFIED_STARTUP}
