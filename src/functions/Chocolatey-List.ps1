function Chocolatey-List {
param(
  [string] $selector='', 
  [string] $source='' 
)
  Write-Debug "Running 'Chocolatey-List' with selector: `'$selector`', source:`'$source`'";

  if ($source -like 'webpi') {
    $webpiArgs ="/c webpicmd /List /ListOption:All"
    & cmd.exe $webpiArgs 
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
    
    Write-Debug "Calling nuget with `'$parameters $srcArgs`'"
    $parameters = "$parameters $srcArgs"

    Start-Process $nugetExe -ArgumentList $parameters -NoNewWindow -Wait 
  }
}