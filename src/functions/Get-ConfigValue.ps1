function Get-ConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)

if ($globalConfig -eq '') {
    $globalConfigFile = Join-Path $nugetChocolateyPath chocolatey.config
    $globalConfig = [xml] (Get-Content $globalConfigFile)
}

if ($userConfig -eq '') {
    #$env:USERPROFILE or $env:HOME
    $userConfigFile = Join-Path $env:USERPROFILE chocolatey.config
    $userConfig = $globalConfig
    
    if (Test-Path($userConfigFile)) {
        $userConfig = [xml] (Get-Content $userConfigFile)
    }
}


#write-host "$($globalConfig.chocolatey.core.useNuGetForSources)"
#$useNuGetForSources = $false
[bool] $useNuGetForSources = $globalConfig.chocolatey.core.useNuGetForSources -eq 'true'

write-host "$useNuGetForSources"
  
}