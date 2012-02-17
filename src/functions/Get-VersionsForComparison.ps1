Function Get-VersionsForComparison {
param (
 $packageVersions = @()
)

  $versionsForComparison = @{}
  foreach ($packageVersion in $packageVersions) {
    $longVersion = Get-LongPackageVersion $packageVersion
    $versionsForComparison.Add($longVersion,$packageVersion)
  } 
  return $versionsForComparison
}