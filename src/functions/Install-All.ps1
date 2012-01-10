
function Chocolatey-InstallAll {
param(
  [string]$source = ''
)

  if ($source -eq '' -or $source -eq 'https://go.microsoft.com/fwlink/?LinkID=206669' -or $source -eq 'http://chocolatey.org/api/feeds/') {
    write-host 'Source must be specified and cannot be nuget.org/chocolatey.org'
    return
  }
  
  if ($source.StartsWith('http')) {
    $webClient = New-Object System.Net.WebClient
    
    if (!$source.EndsWith('/')) { $source = $source + '/' }
    $feedUrl = $source + 'Packages/' 
    write-host "Installing all packages from $feedUrl"
    
    $feed = [xml]$webClient.DownloadString($feedUrl) 
    $entries = $feed | select -ExpandProperty feed | select -ExpandProperty entry  
    foreach ($entry in $entries) {
      if ($entry.properties.id -ne $null) {
        Chocolatey-NuGet $entry.properties.id -version $entry.properties.version -source $source
      }
    } 
  } else {
    $files = get-childitem $source -include *.nupkg -recurse
    foreach ($file in $files) {
      $packageName = $file.Name -replace "(\.\d{1,})+.nupkg"
      Chocolatey-NuGet $packageName -source $source
    }
  }
}