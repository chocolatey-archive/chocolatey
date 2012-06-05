function Get-ConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)
  
  $script:get_configvalue_was_called = $true
  $script:configValue = $configValue
  
  if ($script:exec_get_configvalue_actual) { 
    $script:get_configvalue_actual_was_called = $true
    Get-ConfigValue-Actual @PSBoundParameters
  } else {
    return $script:get_configvalue_return_value
  }
}