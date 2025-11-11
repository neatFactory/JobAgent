# Get the directory where the script is located
$scriptDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $scriptDir

# Set the ASP.NET Core environment to Development
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:DOTNET_ENVIRONMENT = "Development"

# Run the application
.\JobAgent.exe
