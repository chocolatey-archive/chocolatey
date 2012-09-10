function Chocolatey-WindowsFeatures {
param(
  [string] $packageName
)
  $script:chocolatey_windowsfeatures_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_chocolatey_windowsfeatures_actual) { Chocolatey-WindowsFeatures-Actual @PSBoundParameters}
}