function Chocolatey-RubyGem {
param(
  [string] $packageName, 
  [string] $version ='', 
  [string] $installerArguments =''
)
  Write-Debug "Running 'Chocolatey-RubyGem' for $packageName with version:`'$version`', installerArguments: `'$installerArguments`'";

  Chocolatey-InstallIfMissing 'ruby'

  if ($($env:Path).ToLower().Contains("ruby") -eq $false) {
    $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
  }
  
@"
$h1
Chocolatey ($chocVer) is installing Ruby Gem `'$packageName`' (using RubyGems.org). By installing you accept the license for the package you are installing (please run chocolatey /? for full license acceptance terms).
$h1
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyRubyInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $packageArgs = "/c gem install $packageName"
  if ($version -notlike '') {
    Write-Debug "Adding version arguments `'$version`'"
    $packageArgs = "$packageArgs -v $version";
  }
  
  if ($installerArguments -ne '') {
    Write-Debug "Adding installerArguments `'$installerArguments`'"
    $packageArgs = "$packageArgs $installerArguments";
  }
  Write-Host "Calling cmd.exe $packageArgs"
  & cmd.exe $packageArgs

  #Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath $chocoInstallLog`"" -Wait -WindowStyle Minimized
  
  #Create-InstallLogIfNotExists $chocoInstallLog
  #$installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  #foreach ($line in $installOutput) {
  #  Write-Host $line
  #}
  
@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}