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
    $newVersionDetails=@{
        BUILD_MAJOR=1
        BUILD_MINOR=0
        BUILD_REVISION=0
        BUILD_NUMBER=0
        GIT_COMMIT="UNKNOWN"
        GIT_BRANCH="UNKNOWN"
    }
    $wrap=@{ VersionDetails=$newVersionDetails }
    $wrap | ConvertTo-Json | Out-File $AssemblyVersionsFilePath
}

$versionDetails = (Get-Content -Path $AssemblyVersionsFilePath | ConvertFrom-Json)
Write-Host "VERSIONING: Currently - Major: '$($versionDetails.VersionDetails.BUILD_MAJOR)' Minor: '$($versionDetails.VersionDetails.BUILD_MINOR)' Revision: '$($versionDetails.VersionDetails.BUILD_REVISION)' Build: '$($versionDetails.VersionDetails.BUILD_NUMBER)' Commit: '$($Env:GIT_COMMIT)' Branch: ' $($Env:GIT_BRANCH)'"

#Env overrides
if($Env:BUILD_MAJOR) {
    $versionDetails.VersionDetails.BUILD_MAJOR = $Env:BUILD_MAJOR
}
if($Env:BUILD_MINOR) {
    $versionDetails.VersionDetails.BUILD_MINOR = $Env:BUILD_MINOR
}
if($Env:BUILD_REVISION) {
    $versionDetails.VersionDetails.BUILD_REVISION = $Env:BUILD_REVISION
} else {
    $versionDetails.VersionDetails.BUILD_REVISION = $versionDetails.VersionDetails.BUILD_REVISION + 1
}
if($Env:BUILD_NUMBER) {
    $versionDetails.VersionDetails.BUILD_NUMBER = $Env:BUILD_NUMBER
}
if($Env:GIT_COMMIT) {
    $versionDetails.VersionDetails.GIT_COMMIT = $Env:GIT_COMMIT
} else {
    $versionDetails.VersionDetails.GIT_COMMIT = (git rev-parse --verify HEAD)
}
if($Env:GIT_BRANCH) {
    $versionDetails.VersionDetails.GIT_BRANCH = $Env:GIT_BRANCH
} else {
    $versionDetails.VersionDetails.GIT_BRANCH = (git rev-parse --abbrev-ref HEAD)
}

#Write out
$versionDetails | ConvertTo-Json | Out-File $AssemblyVersionsFilePath

Write-Host "VERSIONING: NEW - Major: '$($versionDetails.VersionDetails.BUILD_MAJOR)' Minor: '$($versionDetails.VersionDetails.BUILD_MINOR)' Revision: '$($versionDetails.VersionDetails.BUILD_REVISION)' Build: '$($versionDetails.VersionDetails.BUILD_NUMBER)' Commit: '$($versionDetails.VersionDetails.GIT_COMMIT)' Branch: '$($versionDetails.VersionDetails.GIT_BRANCH)'"
