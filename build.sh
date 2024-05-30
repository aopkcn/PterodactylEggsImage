#!/bin/bash

# 构建镜像
docker build -t games:valheim .


# GitHub 用户名和镜像名称
GHCR_USERNAME="aopkcn"
REPOSITORY_NAME="games"
IMAGE_TAG="valheim"

# 登录到 GitHub Container Registry
echo "key" | docker login ghcr.io -u $GHCR_USERNAME --password-stdin

# 重新打标签
docker tag $REPOSITORY_NAME:$IMAGE_TAG ghcr.io/$GHCR_USERNAME/$REPOSITORY_NAME:$IMAGE_TAG

# 推送镜像
docker push ghcr.io/$GHCR_USERNAME/$REPOSITORY_NAME:$IMAGE_TAG

# 检查推送状态
if [ $? -eq 0 ]; then
  echo "镜像推送成功！"
else
  echo "镜像推送失败！"
fi
