function Chocolatey-Python {
param(
  [string] $packageName,
  [string] $version ='',
  [string] $installerArguments =''
)

  Write-Debug "Running 'Chocolatey-Python' for $packageName with version:`'$version`', installerArguments: `'$installerArguments`'";

  Chocolatey-InstallIfMissing 'python'

  if ($($env:Path).ToLower().Contains("python") -eq $false) {
    $env:Path = Get-EnvironmentVariable -Name 'Path' -Scope Machine
  }

  Chocolatey-InstallIfMissing 'easy.install'

  Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies (using Python). By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black


  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyPythonInstall.log';
  Append-Log $chocoInstallLog

  $packageArgs = "/c easy_install $packageName"
  if ($version -notlike '') {
    Write-Debug "Adding version arguments `'$version`'"
    $packageArgs = "/c easy_install $packageName==$version";
  }

  if ($installerArguments -ne '') {
    Write-Debug "Adding installerArguments `'$installerArguments`'"
    $packageArgs = "$packageArgs $installerArguments";
  }

  #Write-Debug "Running `'cmd.exe $packageArgs`'' and saving to `'$chocoInstallLog`'"
  #& cmd.exe $packagesArgs | Tee-Object -FilePath $chocoInstallLog

  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..." -ForegroundColor $Warning -BackgroundColor Black
  $process = Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`'`"" -Wait -WindowStyle Minimized -PassThru
  # this is here for specific cases in Posh v3 where -Wait is not honored
  try { if (!($process.HasExited)) { Wait-Process $process } } catch { }

  Create-InstallLogIfNotExists $chocoInstallLog
  $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  foreach ($line in $installOutput) {
    Write-Host $line
  }

  Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
}
