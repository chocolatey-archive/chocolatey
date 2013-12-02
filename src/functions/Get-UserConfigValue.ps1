function Get-UserConfigValue {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $configValue
)
  Write-Debug "Running 'Get-UserConfigValue' with configValue:`'$configValue`'";

    if ($userConfig -eq $null -or $userConfig -eq '') {
        #$env:USERPROFILE or $env:HOME
        $userConfigFile = Join-Path $env:USERPROFILE chocolatey.config

        if (-not(Test-Path($userConfigFile))) {
      return $null
        }
        $userConfig = [xml] (Get-Content $userConfigFile)
    }

    # append chocolatey
    $configValue = "chocolatey.$configValue"

    iex "`$userConfig.$configValue"
}
