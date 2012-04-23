function Get-ChocolateyUnzip {
param(
  [string] $fileFullPath, 
  [string] $destination
)

	$script:get_chocolateyunzip_was_called = $true
  $script:fileFullPath = $fileFullPath
  $script:destination = $destination
  
  if ($script:exec_get_chocolateyunzip_actual) { Get-ChocolateyUnzip-Actual @PSBoundParameters}
}