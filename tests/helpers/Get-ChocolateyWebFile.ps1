function Get-ChocolateyWebFile {
param(
  [string] $packageName,
  [string] $fileFullPath,
  [string] $url,
  [string] $url64bit
)
  
  $script:get_chocolateywebfile_was_called = $true
  $script:packageName = $packageName
  $script:fileFullPath = $fileFullPath
  $script:url = $url
  $script:url64bit = $url64bit
  
  if ($script:exec_get_chocolateywebfile_actual) { Get-ChocolateyWebFile-Actual @PSBoundParameters}
}