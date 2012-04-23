function Get-PackageFoldersForPackage {
param(
  [string] $packageName
)
  
  $script:get_packagefoldersforpackage_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_get_packagefoldersforpackage_actual) { Get-PackageFoldersForPackage-Actual @PSBoundParameters}
}