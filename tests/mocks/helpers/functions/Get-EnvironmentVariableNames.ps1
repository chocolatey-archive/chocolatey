function Get-EnvironmentVariableNames([System.EnvironmentVariableTarget] $Scope) {
    Write-Verbose "Mocked Get-EnvironmentVariableNames scope: $Scope"
    if ($global:ChocolateyTestEnvironmentVariables -eq $null) {
        throw 'Environment mocking has not been set up. Please use Execute-WithEnvironmentProtection.'
    }

    switch ($Scope) {
        'User' { return @($global:ChocolateyTestEnvironmentVariables.user.Keys) }
        'Machine' { return @($global:ChocolateyTestEnvironmentVariables.machine.Keys) }
        'Process' { Get-ChildItem Env:\ | Select-Object -ExpandProperty Key }
        default { throw "Unsupported environment scope: $Scope" }
    }
}
