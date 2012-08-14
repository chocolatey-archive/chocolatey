function Get-ConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)
	Write-Debug "Running 'Get-ConfigValue' with configValue:`'$configValue`'";

    $returnValue = Get-UserConfigValue $configValue
    Write-Debug "After checking the user config the value of `'$configValue`' is `'$returnValue`'"
	
    if ($returnValue -eq $null -or $returnValue -eq '') {
        Write-Debug "Value not found in the user config file - checking the global config"
		
    	$returnValue = Get-GlobalConfigValue $configValue
        Write-Debug "After checking the global config the value of `'$configValue`' is `'$returnValue`'"
    }

    if ($returnValue -eq $null) {
        Write-Error "A configuration value for $configValue was not found"
    }

    $returnValue
}
