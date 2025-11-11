# publish.ps1
param(
    [string]$SolutionPath = "..\..\JobAgent.sln",
    [string]$ConsoleProject = "..\..\JobAgent.Console/JobAgent.Console.csproj",
    [string]$PluginProject = "..\..\JobSamples/JobSamples.csproj",
    [string]$OutputDir = "..\..\publish",
    [string]$Runtime = "win-x64"
)

# win-x64
# linux-x64
# linux-arm64
# osx-x64

# 1️⃣ 清理输出目录
Write-Host "Cleaning output directory..."
Remove-Item -Recurse -Force "$OutputDir" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$OutputDir"

# 2️⃣ 恢复依赖
Write-Host "Restoring dependencies..."
dotnet restore $SolutionPath

# 3️⃣ 发布插件项目（非自包含）
$pluginOutput = Join-Path $OutputDir "JobSamples"
Write-Host "Building plugin project to $pluginOutput ..."
dotnet build $PluginProject -c Release -r $Runtime --self-contained $false -o $pluginOutput

# 4️⃣ 发布 Console 主程序（自包含单文件）
$consoleOutput = Join-Path $OutputDir "JobAgent"
Write-Host "Publishing console project to $consoleOutput ..."
dotnet publish $ConsoleProject -c Release -r $Runtime --self-contained $true `
    -p:PublishSingleFile=true `
    -o $consoleOutput

# 5️⃣ 拷贝插件到 Console 的 Plugins 目录
$pluginTarget = Join-Path $consoleOutput "Plugins/JobSamples"
Write-Host "Copying plugin to $pluginTarget ..."
New-Item -ItemType Directory -Force -Path $pluginTarget
Copy-Item -Path "$pluginOutput/*" -Destination $pluginTarget -Recurse -Force


Write-Host "✅ Build and copy completed successfully!"
Write-Host "Console output: $consoleOutput"
Write-Host "Plugin output: $pluginTarget"
