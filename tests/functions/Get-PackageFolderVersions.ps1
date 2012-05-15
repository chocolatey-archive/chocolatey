function Get-PackageFolderVersions {
param(
  [string] $packageName
)

  $script:get_packagefolderversions_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_get_packagefolderversions_actual) { 
    	$script:get_packagefolderversions_actual_was_called = $true
      Get-PackageFolderVersions-Actual @PSBoundParameters
	} else {
		return $script:get_packagefolderversions_return_value
	}
}