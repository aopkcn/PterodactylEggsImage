# 声明一个构建参数，用于在基础镜像名称中添加后缀（例如，用于指定特定的版本或变体）。
ARG IMAGESUFFIX

# 第一个阶段：构建 ASF-ui
# 使用指定的 Node.js LTS 版本基础镜像
FROM --platform=$BUILDPLATFORM node:lts${IMAGESUFFIX} AS build-node

# 设置工作目录
WORKDIR /app/ASF-ui

# 复制 ASF-ui 源代码和 Git 子模块
COPY ASF-ui .
COPY .git/modules/ASF-ui /app/.git/modules/ASF-ui

# 安装依赖并构建项目
RUN <<EOF
    set -eu

    echo "node: $(node --version)"
    echo "npm: $(npm --version)"

    npm ci --no-progress
    npm run deploy --no-progress
EOF

# 第二个阶段：构建 .NET 项目
# 使用指定的 .NET SDK 8.0 基础镜像
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0${IMAGESUFFIX} AS build-dotnet

# 声明构建参数和环境变量
ARG CONFIGURATION=Release
ARG TARGETARCH
ARG TARGETOS
ENV DOTNET_CLI_TELEMETRY_OPTOUT true
ENV DOTNET_NOLOGO true
ENV PLUGINS_BUNDLED ArchiSteamFarm.OfficialPlugins.ItemsMatcher ArchiSteamFarm.OfficialPlugins.MobileAuthenticator ArchiSteamFarm.OfficialPlugins.SteamTokenDumper

# 设置工作目录
WORKDIR /app

# 复制从第一个阶段生成的 ASF-ui 静态文件和 .NET 项目文件
COPY --from=build-node /app/ASF-ui/dist ASF-ui/dist
COPY ArchiSteamFarm ArchiSteamFarm
COPY ArchiSteamFarm.OfficialPlugins.ItemsMatcher ArchiSteamFarm.OfficialPlugins.ItemsMatcher
COPY ArchiSteamFarm.OfficialPlugins.MobileAuthenticator ArchiSteamFarm.OfficialPlugins.MobileAuthenticator
COPY ArchiSteamFarm.OfficialPlugins.SteamTokenDumper ArchiSteamFarm.OfficialPlugins.SteamTokenDumper
COPY resources resources
COPY .editorconfig .editorconfig
COPY Directory.Build.props Directory.Build.props
COPY Directory.Packages.props Directory.Packages.props
COPY LICENSE.txt LICENSE.txt

# 使用构建参数和挂载的秘密文件进行构建和发布
RUN --mount=type=secret,id=ASF_PRIVATE_SNK --mount=type=secret,id=STEAM_TOKEN_DUMPER_TOKEN <<EOF
    set -eu

    dotnet --info

    # 根据目标操作系统和架构设置变体名称
    case "$TARGETOS" in
        "linux") ;;
        *) echo "ERROR: Unsupported OS: ${TARGETOS}"; exit 1 ;;
    esac

    case "$TARGETARCH" in
        "amd64") asf_variant="${TARGETOS}-x64" ;;
        "arm") asf_variant="${TARGETOS}-${TARGETARCH}" ;;
        "arm64") asf_variant="${TARGETOS}-${TARGETARCH}" ;;
        *) echo "ERROR: Unsupported CPU architecture: ${TARGETARCH}"; exit 1 ;;
    esac

    # 如果提供了 ASF 私钥，解码并存储
    if [ -f "/run/secrets/ASF_PRIVATE_SNK" ]; then
        base64 -d "/run/secrets/ASF_PRIVATE_SNK" > "resources/ArchiSteamFarm.snk"
    else
        echo "WARN: No ASF_PRIVATE_SNK provided!"
    fi

    # 发布主项目
    dotnet publish ArchiSteamFarm -c "$CONFIGURATION" -o "out" -p:ASFVariant=docker -p:ContinuousIntegrationBuild=true -p:UseAppHost=false -r "$asf_variant" --nologo --no-self-contained

    # 如果提供了 Steam Token Dumper 令牌，替换相关文件中的占位符
    if [ -f "/run/secrets/STEAM_TOKEN_DUMPER_TOKEN" ]; then
        STEAM_TOKEN_DUMPER_TOKEN="$(cat "/run/secrets/STEAM_TOKEN_DUMPER_TOKEN")"

        if [ -n "$STEAM_TOKEN_DUMPER_TOKEN" ] && [ -f "ArchiSteamFarm.OfficialPlugins.SteamTokenDumper/SharedInfo.cs" ]; then
            sed -i "s/STEAM_TOKEN_DUMPER_TOKEN/${STEAM_TOKEN_DUMPER_TOKEN}/g" "ArchiSteamFarm.OfficialPlugins.SteamTokenDumper/SharedInfo.cs"
        else
            echo "WARN: STEAM_TOKEN_DUMPER_TOKEN not applied!"
        fi
    else
        echo "WARN: No STEAM_TOKEN_DUMPER_TOKEN provided!"
    fi

    # 发布所有捆绑的插件
    for plugin in $PLUGINS_BUNDLED; do
        dotnet publish "$plugin" -c "$CONFIGURATION" -o "out/plugins/$plugin" -p:ASFVariant=docker -p:ContinuousIntegrationBuild=true -p:UseAppHost=false -r "$asf_variant" --nologo
    done
EOF

# 第三个阶段：创建最终的运行时镜像
# 使用指定的 .NET ASP.NET 运行时镜像
FROM --platform=$TARGETPLATFORM mcr.microsoft.com/dotnet/aspnet:8.0${IMAGESUFFIX} AS runtime

# 设置环境变量
ENV ASF_PATH /app
ENV ASF_USER asf
ENV ASPNETCORE_URLS=
ENV DOTNET_CLI_TELEMETRY_OPTOUT true
ENV DOTNET_NOLOGO true

# 添加镜像标签
LABEL maintainer="JustArchi <JustArchi@JustArchi.net>" \
    org.opencontainers.image.authors="JustArchi <JustArchi@JustArchi.net>" \
    org.opencontainers.image.url="https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Docker" \
    org.opencontainers.image.documentation="https://github.com/JustArchiNET/ArchiSteamFarm/wiki" \
    org.opencontainers.image.source="https://github.com/JustArchiNET/ArchiSteamFarm" \
    org.opencontainers.image.vendor="JustArchiNET" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.title="ArchiSteamFarm" \
    org.opencontainers.image.description="C# application with primary purpose of idling Steam cards from multiple accounts simultaneously"

# 暴露端口
EXPOSE 1242

# 复制从第二阶段生成的输出文件
COPY --from=build-dotnet /app/out /asf

# 创建必要的目录和设置权限
RUN <<EOF
    set -eu

    mkdir -p "$ASF_PATH"

    groupadd -r -g 1000 "$ASF_USER"
    useradd -r -d "$ASF_PATH" -g 1000 -u 1000 "$ASF_USER"
    chown -hR "${ASF_USER}:${ASF_USER}" "$ASF_PATH" /asf

    ln -s /asf/ArchiSteamFarm.sh /usr/bin/ArchiSteamFarm
EOF

# 设置工作目录和卷
WORKDIR /app
VOLUME ["/app/config", "/app/logs"]

# 设置健康检查
HEALTHCHECK CMD ["pidof", "-q", "dotnet"]

# 设置入口点
ENTRYPOINT ["ArchiSteamFarm", "--no-restart", "--system-required"]
