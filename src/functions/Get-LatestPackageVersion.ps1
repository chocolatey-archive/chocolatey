function Get-LatestPackageVersion {
param(
  $packageVersions = @()
)
  $latestVersion = ''
  if ($packageVersions -ne $null -and $packageVersions.GetEnumerator() -ne $null) {
    $packageVersions = $packageVersions.GetEnumerator() | sort-object -property Name -descending
    if ($packageVersions -is [Object[]]) {
      $latestPackageVersion = $packageVersions.GetEnumerator() | Select-Object -First 1
      Write-Debug "Using $($latestPackageVersion.Value) as the latest version (from multiple found versions)"
      $latestVersion = $latestPackageVersion.Value
    }
	else {
    Write-Debug "Using $($packageversions.value) as the latest version"
		$latestversion=$packageversions.value
	}
  }
 
  return $latestVersion
}