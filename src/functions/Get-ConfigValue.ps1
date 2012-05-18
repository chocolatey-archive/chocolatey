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

#append chocolatey
$configValue = "chocolatey.core.$configValue"
write-host "$configValue"
$returnValue = $globalConfigFile.$configValue
if ($returnValue -eq $null -or $returnValue -eq '') {
    #append core if not found

}

Write-host "$returnValue"


#write-host "$($globalConfig.chocolatey.core.useNuGetForSources)"
#$useNuGetForSources = $false
[bool] $useNuGetForSources = $globalConfig.chocolatey.core.useNuGetForSources -eq 'true'

#write-host "$useNuGetForSources"
  
  $returnValue
}