function Get-LongPackageVersion {
param(
 [string] $packageVersion
)

  $script:get_longpackageversion_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_get_longpackageversion_actual) { Get-LongPackageVersion-Actual @PSBoundParameters}
}