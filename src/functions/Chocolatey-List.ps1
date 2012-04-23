function Chocolatey-List {
param(
  [string] $selector='', 
  [string] $source='https://go.microsoft.com/fwlink/?LinkID=230477' 
)
  
  if ($source -like 'webpi') {
    $webpiArgs ="/c webpicmd /List /ListOption:All"
    & cmd.exe $webpiArgs 
  } else {  
  
    $srcArgs = "-Source `"$source`""
    if ($source -like 'https://go.microsoft.com/fwlink/?LinkID=230477') {
      $srcArgs = "-Source `"http://chocolatey.org/api/v2/`" -Source `"$source`""
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