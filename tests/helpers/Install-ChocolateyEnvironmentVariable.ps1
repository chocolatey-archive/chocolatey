function Install-ChocolateyEnvironmentVariable {
param(
  [string] $variableName,
  [string] $variableValue,
  [System.EnvironmentVariableTarget] $variableType = [System.EnvironmentVariableTarget]::User
)

  $script:install_chocolateyenvironmentvariable_was_called = $true
  $script:variableName = $variableName
  $script:variableValue = $variableValue  
  $script:variableType = $variableType
  
  if ($script:exec_install_chocolateyenvironmentvariable_actual) { Install-ChocolateyEnvironmentVariable-Actual @PSBoundParameters}
}