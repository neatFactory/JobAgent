# ==============================================================================
# 公共 build 阶段（只做编译）
# ==============================================================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["nuget.config", "./"]

# --- 1. 先编译插件 JobSamples ---
COPY ["JobSamples/JobSamples.csproj", "JobSamples/"]
RUN dotnet restore JobSamples/JobSamples.csproj --runtime linux-x64
COPY ["JobSamples/", "JobSamples/"]
RUN dotnet build JobSamples/JobSamples.csproj \
    -c Release \
    -o /plugin/Plugins/JobSamples \
    -r linux-x64 \
    -p:PublishReadyToRun=true \
    -p:PublishSingleFile=false \
    -p:SelfContained=false

# --- 2. 再发布宿主 JobAgent.Console ---
COPY ["JobAgent.sln", "."]
COPY ["JobAgent.Console/JobAgent.Console.csproj", "JobAgent.Console/"]
RUN dotnet restore JobAgent.Console/JobAgent.Console.csproj --runtime linux-x64
COPY ["JobAgent.Console/", "JobAgent.Console/"]
RUN dotnet publish JobAgent.Console/JobAgent.Console.csproj \
    -c Release \
    -o /app \
    -r linux-x64 \
    -p:PublishReadyToRun=true \
    -p:PublishSingleFile=true \
    -p:SelfContained=false

# 提前建好目录并赋权（在 build 容器里操作，下面会被 COPY 走）
RUN mkdir -p /app/states /app/logs /app/Plugins && \
    chmod -R 755 /app/states /app/logs && \
    chown -R 65532:65532 /app/states /app/logs

# ==============================================================================
# 阶A：chiseled 瘦镜像（生产用）（chiseled —— 无 sh、无 chmod） 1.2.3.4 | 普通版本 | root权限 + 无shell
# ==============================================================================
FROM mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled AS chiseled
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["./JobAgent"]

# ==============================================================================
# 阶B：chiseled 瘦镜像（生产用）（chiseled —— 无 sh、无 chmod） secure  | 安全版本 | 最小权限 + 无shell
# ==============================================================================
FROM mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled AS secure
WORKDIR /app
COPY --from=build --chown=65532:65532 /app .
USER 65532
ENTRYPOINT ["./JobAgent"]

# ==============================================================================
# 阶段C：带 SDK 的 debug 调试镜像（调试/排障用|带 shell）  debug   | 测试版本 | root根限 + 有shell + JobSamples插件
# ==============================================================================
FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS debug
WORKDIR /app
COPY --from=build /app /plugin ./
ENTRYPOINT ["./JobAgent"]
