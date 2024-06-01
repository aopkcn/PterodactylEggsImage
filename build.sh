#!/bin/bash

# 设置参数
#GitHub用户名
GHCR_USERNAME="aopkcn"
#key
GHCR_KEY=""
#Docker用户名
DOCKER_USERNAME="aopkcn"
#Docker密码
DOCKER_PASSWD=""
#阿里云邮箱
ALICLOUD_USERNAME=""
#阿里云密码
ALICLOUD_PASSWORD=""
ALICLOUD_REGISTRY="registry.cn-chengdu.aliyuncs.com"
# 替换为你的阿里云命名空间
ALICLOUD_NAMESPACE=""  
#镜像名称
REPOSITORY_NAME="games"
#镜像标签
IMAGE_TAG="installers"

# 构建镜像
docker build -t $REPOSITORY_NAME:$IMAGE_TAG .

# 登录到 GitHub Container Registry
echo $GHCR_KEY | docker login ghcr.io -u $GHCR_USERNAME --password-stdin
if [ $? -ne 0 ]; then
  echo "登录到 GitHub Container Registry 失败！"
  exit 1
fi

# 推送到 GitHub Container Registry
GHCR_IMAGE_TAG="ghcr.io/$GHCR_USERNAME/$REPOSITORY_NAME:$IMAGE_TAG"
docker tag $REPOSITORY_NAME:$IMAGE_TAG $GHCR_IMAGE_TAG
docker push $GHCR_IMAGE_TAG
if [ $? -eq 0 ]; then
  echo "镜像推送到 GitHub Container Registry 成功！"
else
  echo "镜像推送到 GitHub Container Registry 失败！"
  exit 1
fi

# 登录到 Docker Hub
echo $DOCKER_PASSWD | docker login docker.io -u $DOCKER_USERNAME --password-stdin
if [ $? -ne 0 ]; then
  echo "登录到 Docker Hub 失败！"
  exit 1
fi

# 推送到 Docker Hub
DOCKER_IMAGE_TAG="docker.io/$DOCKER_USERNAME/$REPOSITORY_NAME:$IMAGE_TAG"
docker tag $REPOSITORY_NAME:$IMAGE_TAG $DOCKER_IMAGE_TAG
docker push $DOCKER_IMAGE_TAG
if [ $? -eq 0 ]; then
  echo "镜像推送到 Docker Hub 成功！"
else
  echo "镜像推送到 Docker Hub 失败！"
  exit 1
fi

# 登录到阿里云容器镜像服务
echo $ALICLOUD_PASSWORD | docker login $ALICLOUD_REGISTRY -u $ALICLOUD_USERNAME --password-stdin
if [ $? -ne 0 ]; then
  echo "登录到阿里云容器镜像服务失败！"
  exit 1
fi

# 推送到阿里云容器镜像服务
ALICLOUD_IMAGE_TAG="$ALICLOUD_REGISTRY/$ALICLOUD_NAMESPACE/$REPOSITORY_NAME:$IMAGE_TAG"
docker tag $REPOSITORY_NAME:$IMAGE_TAG $ALICLOUD_IMAGE_TAG
docker push $ALICLOUD_IMAGE_TAG
if [ $? -eq 0 ]; then
  echo "镜像推送到阿里云容器镜像服务成功！"
else
  echo "镜像推送到阿里云容器镜像服务失败！"
  exit 1
fi
