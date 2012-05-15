function Get-VersionsForComparison {
param (
  $packageVersions = @()
)

  $versionsForComparison = @{}
  foreach ($packageVersion in $packageVersions) {
    $longVersion = Get-LongPackageVersion $packageVersion
    if ($versionsForComparison.ContainsKey($longVersion) -ne $true) {
      $versionsForComparison.Add($longVersion,$packageVersion)
    }
    
  } 
  
  return $versionsForComparison
}