function Get-VersionsForComparison {
param (
  $packageVersions = @()
)

  $script:get_versionsforcomparison_was_called = $true
  $script:packageVersions = $packageVersions
 
  if ($script:exec_get_versionsforcomparison_actual) { Get-VersionsForComparison-Actual @PSBoundParameters}
}