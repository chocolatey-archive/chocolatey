function Get-EnvironmentVariable([string] $Name, [System.EnvironmentVariableTarget] $Scope) {
    Write-Verbose "Mocked Get-EnvironmentVariable scope: $Scope name: $Name"
    if ($global:ChocolateyTestEnvironmentVariables -eq $null) {
        throw 'Environment mocking has not been set up. Please use Execute-WithEnvironmentProtection.'
    }

    switch ($Scope) {
        'User' { return $global:ChocolateyTestEnvironmentVariables.user[$Name] }
        'Machine' { return $global:ChocolateyTestEnvironmentVariables.machine[$Name] }
        'Process' { return Get-Content "Env:\$Name" }
        default { throw "Unsupported environment scope: $Scope" }
    }
}
