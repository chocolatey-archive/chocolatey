function Chocolatey-WebPI {
param(
  [string] $packageName, 
  [string] $installerArguments =''
)

  Chocolatey-InstallIfMissing 'webpicommandline'
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (using WebPI). By installing you accept the license for the package you are installing (please run chocolatey /? for full license acceptance terms).
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWebPiInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $webpiArgs = "/c webpicmd /Install /AcceptEula /SuppressReboot /Products:$packageName"
  if ($installerArguments -ne '') {
    $webpiArgs = "$webpiArgs $installerArguments"
  }
  if ($overrideArgs -eq $true) {
    $webpiArgs = "/c webpicmd $installerArguments /Products:$packageName"
    write-host "Overriding arguments for WebPI"
  }  
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $webpiArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  
  #Start-Process -FilePath "cmd" -ArgumentList "$webpiArgs" -Verb "runas"  -Wait >$chocoInstallLog #-PassThru -UseNewEnvironment >
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $webpiArgs | Out-String`"" -Verb "runas"  -Wait | Write-Host  #-PassThru -UseNewEnvironment
  Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $webpiArgs | Tee-Object -FilePath $chocoInstallLog`"" -Verb "RunAs"  -Wait -WindowStyle Minimized
  
  $webpiOutput = Get-Content $chocoInstallLog -Encoding Ascii
	foreach ($line in $webpiOutput) {
    Write-Host $line
  }
  
@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}