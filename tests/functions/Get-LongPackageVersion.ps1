function Get-LongPackageVersion {
param(
 [string] $packageVersion
)

  $script:get_longpackageversion_was_called = $true
  $script:packageVersion = $packageVersion
  
  if ($script:exec_get_longpackageversion_actual) { 
    	$script:get_longpackageversion_actual_was_called = $true
      Get-LongPackageVersion-Actual @PSBoundParameters
	} else {
		return $script:get_longpackageversion_return_value
	}
}