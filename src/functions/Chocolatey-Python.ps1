function Chocolatey-Python {
param(
  [string] $packageName,  
  [string] $version ='', 
  [string] $installerArguments =''
)

  Write-Debug "Running 'Chocolatey-Python' for $packageName with version:`'$version`', installerArguments: `'$installerArguments`'";

  Chocolatey-InstallIfMissing 'python'

  if ($($env:Path).ToLower().Contains("python") -eq $false) {
    $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
  }

  Chocolatey-InstallIfMissing 'easy.install'
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (using Python). By installing you accept the license for the package you are installing (please run chocolatey /? for full license acceptance terms).
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyPythonInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
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

  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`'`"" -Wait -WindowStyle Minimized
  
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