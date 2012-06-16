function Install-ChocolateyPowershellCommand {
param(
  [string] $packageName,
  [string] $psFileFullPath, 
  [string] $url ='',
  [string] $url64bit = $url
)
  Write-Debug "Running 'Install-ChocolateyPowershellCommand' for $packageName with psFileFullPath:`'$psFileFullPath`', url: `'$url`', url64bit:`'$url64bit`' ";
  
  try {

    if ($url -ne '') {
      Get-ChocolateyWebFile $packageName $psFileFullPath $url $url64bit
    }

    $nugetPath = $(Split-Path -parent $(Split-Path -parent $helpersPath))
    $nugetExePath = Join-Path $nuGetPath 'bin'
    
    $cmdName = [System.IO.Path]::GetFileNameWithoutExtension($psFileFullPath)
    $packageBatchFileName = Join-Path $nugetExePath "$($cmdName).bat"

    Write-Host "Adding $packageBatchFileName and pointing it to powershell command $psFileFullPath"
"@echo off
powershell -NoProfile -ExecutionPolicy unrestricted -Command ""& `'$psFileFullPath`'  %*"""| Out-File $packageBatchFileName -encoding ASCII 
 
    Write-ChocolateySuccess $packageName
  } catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw 
  } 
}