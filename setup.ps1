### install chocolatey ###
if(-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall")){
  iex ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))
} else {
  Write-Host "Chocolatey Install located at $($env:ChocolateyInstall)"
}

$chocoDir = $env:ChocolateyInstall
if(!$chocoDir){$chocoDir="$env:AllUsersProfile\chocolatey"}
if(!(Test-Path($chocoDir))){$chocoDir="$env:SystemDrive\chocolatey"}
$chocoDir = $chocoDir.Replace("\bin","")
$env:Path +=";$chocoDir\bin;"
Write-Host "Path is $($env:Path)"

# install nuget if it is missing
cinst nuget.commandline
cinst pester -version 2.0.2
