function Get-PackageFolderVersions {
param(
  [string] $packageName
)

  $script:get_packagefolderversions_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_get_packagefolderversions_actual) { Get-PackageFolderVersions-Actual @PSBoundParameters}
}