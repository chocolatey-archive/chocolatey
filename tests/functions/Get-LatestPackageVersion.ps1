function Get-LatestPackageVersion {
param(
  $packageVersions = @()
)

  $script:get_latestpackageversion_was_called = $true
  $script:packageVersions = $packageVersions
  
  if ($script:exec_get_latestpackageversion_actual) { Get-LatestPackageVersion-Actual @PSBoundParameters}
}