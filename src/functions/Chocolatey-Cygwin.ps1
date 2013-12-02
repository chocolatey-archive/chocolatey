function Chocolatey-Cygwin {
param(
  [string] $packageName,
  [string] $installerArguments =''
)
  Write-Debug "Running 'Chocolatey-Cygwin' for $packageName with installerArguments:`'$installerArguments`'";

  Chocolatey-InstallIfMissing 'cyg-get'


  Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies (using Cygwin). By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black

  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyCygwinInstall.log';
  Append-Log $chocoInstallLog

  $packageArgs = "/c cyg-get $packageName"
  # if ($version -notlike '') {
  #   $packageArgs = "$packageArgs -v $version";
  # }

  if ($installerArguments -ne '') {
    Write-Debug "Adding installerArguments `'$installerArguments`'"
    $packageArgs = "$packageArgs $installerArguments";
  }

  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..." -ForegroundColor $Warning -BackgroundColor Black
  $statements = "cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath $chocoInstallLog; Write-Host 'finished';Start-Sleep 5`"" -Wait -Verb "RunAs" -WindowStyle Minimized | Wait-Process

  Create-InstallLogIfNotExists $chocoInstallLog
  $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  foreach ($line in $installOutput) {
    Write-Host $line
  }


  Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
}
