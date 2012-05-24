function Chocolatey-Cygwin {
param(
  [string] $packageName, 
  [string] $installerArguments =''
)

  Chocolatey-InstallIfMissing 'cyg-get'
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (using Cygwin). By installing you accept the license for the package you are installing (please run chocolatey /? for full license acceptance terms).
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyCygwinInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $cygwinArgs = "/c cyg-get $packageName"
#  if ($installerArguments -ne '') {
#    $cygwinArgs = "$cygwinArgs $installerArguments"
#  }
#  if ($overrideArgs -eq $true) {
#    $cygwinArgs = "/c cyg-get $installerArguments /Products:$packageName"
#    write-host "Overriding arguments for cyg-get"
#  }  
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $cygwinArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  
  #Start-Process -FilePath "cmd" -ArgumentList "$cygwinArgs" -Verb "runas"  -Wait >$chocoInstallLog #-PassThru -UseNewEnvironment >
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $cygwinArgs | Out-String`"" -Verb "runas"  -Wait | Write-Host  #-PassThru -UseNewEnvironment
  Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $cygwinArgs | Tee-Object -FilePath $chocoInstallLog`"" -Verb "RunAs"  -Wait -WindowStyle Minimized
  
  $cygwinOutput = Get-Content $chocoInstallLog -Encoding Ascii
	foreach ($line in $cygwinOutput) {
    Write-Host $line
  }
  
@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}