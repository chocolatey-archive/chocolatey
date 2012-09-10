function Chocolatey-WindowsFeatures {
param(
  [string] $packageName 
)
  Write-Debug "Running 'Chocolatey-WindowsFeatures' for $packageName";
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (from Windows Veatures)..
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWindowsFeaturesInstall.log';
  Remove-LastInstallLog $chocoInstallLog
  $osVersion = (Get-WmiObject -class Win32_OperatingSystem).Version
 
  $packageArgs = "/c DISM /Online /NoRestart /Enable-Feature"
  if($osVersion -ge 6.2) {
    $packageArgs += " /all"
  }
  $packageArgs += " /FeatureName:$packageName"
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  $statements = "cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep -validExitCodes @(0,1)

  Create-InstallLogIfNotExists $chocoInstallLog
  $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  foreach ($line in $installOutput) {
    Write-Host $line
  }
  
@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}