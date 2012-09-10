function Chocolatey-WindowsFeatures {
param(
  [string] $packageName 
)
  Write-Debug "Running 'Chocolatey-WindowsFeatures' for $packageName with installerArguments:`'$installerArguments`'";
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (from Windows Veatures)..
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWindowsFeaturesInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $packageArgs = "/c DISM /Online /NoRestart /Enable-Feature /all /FeatureName:$packageName"
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  $statements = "cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep

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