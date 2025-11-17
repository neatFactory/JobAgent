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
    -o /app/Plugins/JobSamples \
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
RUN mkdir -p /app/states /app/logs && \
    chmod -R 755 /app/states /app/logs && \
    chown -R 65532:65532 /app/states /app/logs

# ==============================================================================
# 阶A：chiseled 瘦镜像（生产用）（chiseled —— 无 sh、无 chmod）
# ==============================================================================
FROM mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled AS chiseled
WORKDIR /app
# 直接拷过去并把属主改成非 root
COPY --from=build --chown=65532:65532 /app .
USER 65532
ENTRYPOINT ["./JobAgent"]

# ==============================================================================
# 阶段B：带 SDK 的 debug 调试镜像（调试/排障用|带 shell）
# ==============================================================================
FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS debug
WORKDIR /app
# 这里不需要改属主，默认 root 即可，方便进去装工具
COPY --from=build /app .
# 如果希望也用非 root，可以照抄上面的 chown，这里省略
ENTRYPOINT ["./JobAgent"]