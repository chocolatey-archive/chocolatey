function Chocolatey-List {
param(
  [string] $selector='', 
  [string] $source='' 
)
  Write-Debug "Running 'Chocolatey-List' with selector: `'$selector`', source:`'$source`'";

  if ($source -like 'webpi') {
    $webpiArgs ="/c webpicmd /List /ListOption:All"
    & cmd.exe $webpiArgs 
  } elseif ($source -like 'windowsfeatures') {
    $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWindowsFeaturesInstall.log';
    Remove-LastInstallLog $chocoInstallLog
    $windowsFeaturesArgs ="/c dism /online /get-features /format:table | Tee-Object -FilePath `'$chocoInstallLog`';"
    Start-ChocolateyProcessAsAdmin "cmd.exe $windowsFeaturesArgs" -nosleep
    Create-InstallLogIfNotExists $chocoInstallLog
    $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
    foreach ($line in $installOutput) {
      Write-Host $line
    }
  } else {  
  
  	$srcArgs = Get-SourceArguments $source
    
    $parameters = "list"
    if ($selector -ne '') {
      $parameters = "$parameters ""$selector"""
    }
    
    if ($allVersions -eq $true) {
      Write-Debug "Showing all versions of packages"
      $parameters = "$parameters -all"
    }
    
    if ($prerelease -eq $true) {
      Write-Debug "Showing prerelease versions of packages"
      $parameters = "$parameters -Prerelease";
    }
    
    if ($verbosity -eq $true) {
      $parameters = "$parameters -verbose";
    }

    Write-Debug "Calling nuget with `'$parameters $srcArgs`'"
    $parameters = "$parameters $srcArgs"

    Start-Process $nugetExe -ArgumentList $parameters -NoNewWindow -Wait 
  }
}