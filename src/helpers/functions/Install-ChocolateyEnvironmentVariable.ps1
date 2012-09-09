function Install-ChocolateyEnvironmentVariable {
param(
  [string] $variableName,
  [string] $variableValue,
  [System.EnvironmentVariableTarget] $variableType = [System.EnvironmentVariableTarget]::User
)
  Write-Debug "Running 'Install-ChocolateyEnvironmentVariable' with variableName:`'$variableName`' and variableValue:`'$variableValue`'";
  
  if ($variableType -eq [System.EnvironmentVariableTarget]::Machine) {
    $psArgs = "[Environment]::SetEnvironmentVariable(`'$variableName`',`'$variableValue`', `'$variableType`')"
    Start-ChocolateyProcessAsAdmin "$psArgs"
  } else {
    [Environment]::SetEnvironmentVariable($variableName, $variableValue, $variableType)
  }    
  
  Set-Content env:\$variableName $variableValue
}