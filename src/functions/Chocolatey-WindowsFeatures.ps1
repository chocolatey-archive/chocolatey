function Chocolatey-WindowsFeatures {
param(
  [string] $packageName 
)
  Write-Debug "Running 'Chocolatey-WindowsFeatures' for $packageName";
  

  Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies (from Windows Features). By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWindowsFeaturesInstall.log';
  Remove-LastInstallLog $chocoInstallLog
  $osVersion = (Get-WmiObject -class Win32_OperatingSystem).Version
 
  $packageArgs = "/c DISM /Online /NoRestart /Enable-Feature"
  if($osVersion -ge 6.2) {
    $packageArgs += " /all"
  }
  $packageArgs += " /FeatureName:$packageName"
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..." -ForegroundColor $Warning -BackgroundColor Black
  $statements = "cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep -validExitCodes @(0,1)

  Create-InstallLogIfNotExists $chocoInstallLog
  $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  foreach ($line in $installOutput) {
    Write-Host $line
  }
  
  Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
}