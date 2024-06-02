#!/bin/bash
TZ=${TZ:-UTC+8}
export TZ
# 将 Docker 内部 IP 地址提供给进程使用。
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

echo -e "设置Steam登录账户"
## 以防万一有人删除默认值.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "使用匿名用户.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "用户设置为 ${STEAM_USER}"
fi


## 如果未设置自动更新或者设置为 1，则更新
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
    # 更新源服务器
    if [ ! -z ${SRCDS_APPID} ]; then
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ "${VALIDATE}" == "1" ]] && printf %s "validate" ) +quit
    else
        echo -e "未设置 appid。正在启动服务器"
    fi

else
    echo -e "自动更新未开启。直接启动服务器"
fi


# 为 NSS Wrapper 设置用户和组 ($NSS_WRAPPER_PASSWD 和 $NSS_WRAPPER_GROUP 已在 Dockerfile 中设置)
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > ${NSS_WRAPPER_PASSWD}

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so

# 替换启动变量
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# 运行服务器
eval ${MODIFIED_STARTUP}
