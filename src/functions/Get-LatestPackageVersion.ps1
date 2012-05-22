function Get-LatestPackageVersion {
param(
  $packageVersions = @()
)
  $latestVersion = ''
  if ($packageVersions -ne $null -and $packageVersions.GetEnumerator() -ne $null) {
    $packageVersions = $packageVersions.GetEnumerator() | sort-object -property Name -descending
    if ($packageVersions -is [Object[]]) {
      $latestPackageVersion = $packageVersions.GetEnumerator() | Select-Object -First 1
      $latestVersion = $latestPackageVersion.Value
    }
	else {
		$latestversion=$packageversions.value
	}
  }
 
  return $latestVersion
}