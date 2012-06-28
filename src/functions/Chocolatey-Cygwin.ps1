function Chocolatey-Cygwin {
param(
  [string] $packageName, 
  [string] $installerArguments =''
)
  Write-Debug "Running 'Chocolatey-Cygwin' for $packageName with installerArguments:`'$installerArguments`'";

  Chocolatey-InstallIfMissing 'cyg-get'
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (using Cygwin). By installing you accept the license for the package you are installing (please run chocolatey /? for full license acceptance terms).
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyCygwinInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $packageArgs = "/c cyg-get $packageName"
  # if ($version -notlike '') {
  #   $packageArgs = "$packageArgs -v $version";
  # }
  
  if ($installerArguments -ne '') {
    Write-Debug "Adding installerArguments `'$installerArguments`'"
    $packageArgs = "$packageArgs $installerArguments";
  }

  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  $statements = "cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath $chocoInstallLog; Write-Host 'finished';Start-Sleep 5`"" -Wait -Verb "RunAs" -WindowStyle Minimized | Wait-Process
  
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