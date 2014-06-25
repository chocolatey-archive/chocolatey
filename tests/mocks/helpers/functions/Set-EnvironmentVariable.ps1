function Set-EnvironmentVariable([string] $Name, [string] $Value, [System.EnvironmentVariableTarget] $Scope) {
    Write-Verbose "Mocked Set-EnvironmentVariable scope: $Scope name: $Name value: $Value"
    if ($global:ChocolateyTestEnvironmentVariables -eq $null) {
        throw 'Environment mocking has not been set up. Please use Execute-WithEnvironmentProtection.'
    }

    switch ($Scope) {
        'User' { $storage = $global:ChocolateyTestEnvironmentVariables.user }
        'Machine' { $storage = $global:ChocolateyTestEnvironmentVariables.machine }
        'Process' { Set-Content "Env:$Name" $Value; return }
        default { throw "Unsupported environment scope: $Scope" }
    }

    if ([string]::IsNullOrEmpty($Value)) { 
        $storage.Remove($Name)
    } else {
        $storage[$Name] = $Value
    }
}
