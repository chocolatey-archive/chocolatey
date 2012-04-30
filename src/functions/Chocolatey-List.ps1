function Chocolatey-List {
param(
  [string] $selector='', 
  [string] $source='' 
)
  
  if ($source -like 'webpi') {
    $webpiArgs ="/c webpicmd /List /ListOption:All"
    & cmd.exe $webpiArgs 
  } else {  
  
    if ($source -ne '') {
    	$srcArgs = "-Source `"$source`""
    }
    
    $parameters = "list"
    if ($selector -ne '') {
      $parameters = "$parameters ""$selector"""
    }
    
    if ($allVersions -eq $true) {
      $parameters = "$parameters -all"
    }
    
    if ($prerelease -eq $true) {
      $parameters = "$parameters -Prerelease";
    }
    
    $parameters = "$parameters $srcArgs"
    #write-host "TEMP: Args - $parameters"

    Start-Process $nugetExe -ArgumentList $parameters -NoNewWindow -Wait 
  }
}