function Get-ConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)
  Write-Debug "Running 'Get-ConfigValue' with configValue:`'$configValue`'";

    if ($globalConfig -eq '') {
        $globalConfigFile = Join-Path $nugetChocolateyPath chocolatey.config
        $globalConfig = [xml] (Get-Content $globalConfigFile)
    }

    if ($userConfig -eq '') {
        #$env:USERPROFILE or $env:HOME
        $userConfigFile = Join-Path $env:USERPROFILE chocolatey.config
        
        $userConfig = $globalConfig
        if (Test-Path($userConfigFile)) {
            Write-Debug "A user config exists. We will use that first."
            $userConfig = [xml] (Get-Content $userConfigFile)
        }
    }

    # append chocolatey
    $configValue = "chocolatey.$configValue"

    $returnValue = iex "`$userConfig.$configValue"
    write-debug "After checking the user config the value of `'$configValue`' is `'$returnValue`'"
    if ($returnValue -eq $null -or $returnValue -eq '') {
        write-debug "Value not found in the user config file - checking the global config"
        $returnValue = iex "`$globalConfig.$configValue"
        write-debug "After checking the global config the value of `'$configValue`' is `'$returnValue`'"
    }

    if ($returnValue -eq $null) {
        write-error "A configuration value for $configValue was not found"
    }

    $returnValue
}