function Chocolatey-WebPI {
param(
  [string] $packageName, 
  [string] $installerArguments =''
)
  Write-Debug "Running 'Chocolatey-WebPI' for $packageName with installerArguments:`'$installerArguments`'";

  Chocolatey-InstallIfMissing 'webpicommandline'

  Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies (using WebPI). By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black

  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWebPiInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $packageArgs = "/c webpicmd /Install /AcceptEula /SuppressReboot /Products:$packageName"
  if ($installerArguments -ne '') {
    Write-Debug "Adding installerArguments `'$installerArguments`'"
    $packageArgs = "$packageArgs $installerArguments"
  }
  
  if ($overrideArgs -eq $true) {
    $packageArgs = "/c webpicmd $installerArguments /Products:$packageName"
    write-host "Overriding arguments for WebPI to be `'$packageArgs`'" 
  }  
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..." -ForegroundColor $Warning -BackgroundColor Black
  $statements = "cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep

  #Start-Process -FilePath "cmd" -ArgumentList "$packageArgs" -Verb "runas"  -Wait >$chocoInstallLog #-PassThru -UseNewEnvironment >
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Out-String`"" -Verb "runas"  -Wait | Write-Host  #-PassThru -UseNewEnvironment
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath $chocoInstallLog`"" -Verb "RunAs"  -Wait -WindowStyle Minimized
  
  Create-InstallLogIfNotExists $chocoInstallLog
  $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  foreach ($line in $installOutput) {
    Write-Host $line
  }
  
  Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
}