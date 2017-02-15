param($MSBuildProjectDirectory, $BuildHost)

Write-Host "VERSIONING: Running versioning script on $(hostname)"

if(!($MSBuildProjectDirectory)) {
    $MSBuildProjectDirectory = $PSScriptRoot
}
$AssemblyVersionsFilePath = "$($MSBuildProjectDirectory)\AssemblyVersion.json"
Write-Host "Using AssemblyVersionsFilePath: $AssemblyVersionsFilePath"

#Default versions
if(!(Test-Path $AssemblyVersionsFilePath) -or ((Get-Content $AssemblyVersionsFilePath) -eq $null))
{
    Write-Host "Creating default file as it's missing"
    $version=@{
        BUILD_MAJOR=1
        BUILD_MINOR=0
        BUILD_REVISION=0
        BUILD_NUMBER=0
        GIT_COMMIT="UNKNOWN"
        GIT_BRANCH="UNKNOWN"
    }
    $version | ConvertTo-Json | Out-File $AssemblyVersionsFilePath
}

$version = (Get-Content -Path $AssemblyVersionsFilePath | ConvertFrom-Json)
Write-Host "VERSIONING: Currently - Major: '$($version.BUILD_MAJOR)' Minor: '$($version.BUILD_MINOR)' Revision: '$($version.BUILD_REVISION)' Build: '$($version.BUILD_NUMBER)' Commit: '$($Env:GIT_COMMIT)' Branch: ' $($Env:GIT_BRANCH)'"

#Env overrides
if($Env:BUILD_MAJOR) {
    $version.BUILD_MAJOR = $Env:BUILD_MAJOR
}
if($Env:BUILD_MINOR) {
    $version.BUILD_MINOR = $Env:BUILD_MINOR
}
if($Env:BUILD_REVISION) {
    $version.BUILD_REVISION = $Env:BUILD_REVISION
} else {
    $version.BUILD_REVISION = $version.BUILD_REVISION + 1
}
if($Env:BUILD_NUMBER) {
    $version.BUILD_NUMBER = $Env:BUILD_NUMBER
}
if($Env:GIT_COMMIT) {
    $version.GIT_COMMIT = $Env:GIT_COMMIT
} else {
    $version.GIT_COMMIT = (git rev-parse --verify HEAD)
}
if($Env:GIT_BRANCH) {
    $version.GIT_BRANCH = $Env:GIT_BRANCH
} else {
    $version.GIT_BRANCH = (git rev-parse --abbrev-ref HEAD)
}

#Write out
$version | ConvertTo-Json | Out-File $AssemblyVersionsFilePath

Write-Host "VERSIONING: NEW - Major: '$($version.BUILD_MAJOR)' Minor: '$($version.BUILD_MINOR)' Revision: '$($version.BUILD_REVISION)' Build: '$($version.BUILD_NUMBER)' Commit: '$($version.GIT_COMMIT)' Branch: '$($version.GIT_BRANCH)'"
