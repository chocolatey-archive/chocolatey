function Get-VersionsForComparison {
param (
  $packageVersions = @()
)

  $script:get_versionsforcomparison_was_called = $true
  $script:packageVersions = $packageVersions
 
  if ($script:exec_get_versionsforcomparison_actual) { 
    	$script:get_versionsforcomparison_actual_was_called = $true
      Get-VersionsForComparison-Actual @PSBoundParameters
	} else {
		return $script:get_versionsforcomparison_return_value
	}
}