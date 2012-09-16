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
  

  Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies (using RubyGems.org). By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black

  
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

  #Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..." -ForegroundColor $Warning -BackgroundColor Black
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $packageArgs | Tee-Object -FilePath $chocoInstallLog`"" -Wait -WindowStyle Minimized
  
  #Create-InstallLogIfNotExists $chocoInstallLog
  #$installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  #foreach ($line in $installOutput) {
  #  Write-Host $line
  #}
  
  Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
}