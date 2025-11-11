##----------------------------------------------------------------
## call in visualstudio build event
##----------------------------------------------------------------
param (
    ##Must pass parameters:
    [string]$TargetProjectName,
    [Parameter(Mandatory = $true)]
    [string]$TargetProjectPath, # The project path relative to the project root directory
    [Parameter(Mandatory = $true)]
    [string]$TargetProjectPluginsPath = 'Plugins',
    ##below is the build varaibles:
    [Parameter(Mandatory = $true)]
    [string]$SolutionDir,
    [Parameter(Mandatory = $true)]
    [string]$OutDir,
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir,
    [string]$TargetPath,
    [string]$ConfigurationName,
    [string]$ProjectName,
    [string]$AssemblyName,
    [string]$PlatformName
)
# Enable DelayedExpansion equivalent in PowerShell
#Set-StrictMode -Version Latest

Write-Host "---------------------- Begin plugin-copy.ps1 ----------------------"

# Write-Host "TargetProjectPath: $TargetProjectPath"
# Write-Host "TargetProjectPluginsPath: $TargetProjectPluginsPath"
# Write-Host "SolutionDir: $SolutionDir"
# Write-Host "ConfigurationName: $ConfigurationName"
# Write-Host "OutDir: $OutDir"
# Write-Host "ProjectDir: $ProjectDir"
# Write-Host "TargetPath: $TargetPath"
# Write-Host "ProjectName: $ProjectName"
# Write-Host "AssemblyName: $AssemblyName"
# Write-Host "PlatformName: $PlatformName"

$sourceProjectBinDir = ("$ProjectDir\$OutDir\") -replace '\\+', '\'
$targetProjectBinDir = ("$SolutionDir\$TargetProjectPath\$OutDir\$TargetProjectPluginsPath\$ProjectName\") -replace '\\+', '\'

Write-Host "sourceProjectBinDir: $sourceProjectBinDir"
Write-Host "targetProjectBinDir: $targetProjectBinDir"

# Create target directory if it doesn't exist
if (-not (Test-Path -Path $targetProjectBinDir)) {
    New-Item -Path $targetProjectBinDir -ItemType Directory | Out-Null
}

Write-Host "Begin copying project $ProjectName job dlls..."
# Copy files and sub-dir from source to target directory
#Copy-Item -Path $sourceProjectBinDir -Destination $targetProjectBinDir -Recurse -Force
Get-ChildItem -Path $sourceProjectBinDir -Recurse | ForEach-Object {
    # Construct the target path to maintain the directory structure.
    $destinationPath = $_.FullName -replace [regex]::Escape($sourceProjectBinDir), $targetProjectBinDir

    if ($_.PSIsContainer) {
        # If it is a directory, create the corresponding target directory (if it does not exist).
        if (-not (Test-Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory
            #Write-Host "Created directory: $destinationPath"
        }
    }
    else {
        # If it is a file, copy the file to the target directory.
        Copy-Item -Path $_.FullName -Destination $destinationPath -Force
        #Write-Host "Copied file: $($_.FullName) to $destinationPath"
        Write-Host "Copied To:  $destinationPath"
    }
}

Write-Host "---------------------- End plugin-copy.ps1 ----------------------"
# Exit the script
exit 0