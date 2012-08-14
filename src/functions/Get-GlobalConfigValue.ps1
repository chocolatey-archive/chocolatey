function Get-GlobalConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)
	Write-Debug "Running 'Get-GlobalConfigValue' with configValue:`'$configValue`'";
  
    if ($globalConfig -eq $null -or $globalConfig -eq '') {
        $globalConfigFile = Join-Path $nugetChocolateyPath chocolatey.config
        $globalConfig = [xml] (Get-Content $globalConfigFile)
    }

    # append chocolatey
    $configValue = "chocolatey.$configValue"

    iex "`$globalConfig.$configValue"
}
