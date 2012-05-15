function Get-PackageFoldersForPackage {
param(
  [string] $packageName
)
  
  $script:get_packagefoldersforpackage_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_get_packagefoldersforpackage_actual) { 
    	$script:get_packagefoldersforpackage_actual_was_called = $true
      Get-PackageFoldersForPackage-Actual @PSBoundParameters
	} else {
		return $script:get_packagefoldersforpackage_return_value
	}
}