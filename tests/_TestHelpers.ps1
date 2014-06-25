$here = Split-Path -Parent $MyInvocation.MyCommand.Definition

Get-ChildItem "$here\mocks" -Filter *.ps1 -Recurse | ForEach-Object { Write-Debug "Importing $($_.FullName)"; . $_.FullName }

function Get-EnvironmentSnapshot()
{
    Write-Debug 'Obtaining snapshot of the environment'
    $machineEnv = @{}
    $key = Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $key.GetValueNames() | ForEach-Object { $machineEnv[$_] = $key.GetValue($_) }

    $userEnv = @{}
    $key = Get-Item 'HKCU:\Environment'
    $key.GetValueNames() | ForEach-Object { $userEnv[$_] = $key.GetValue($_) }

    $processEnv = @{}
    Get-ChildItem Env:\ | ForEach-Object { $processEnv[$_.Key] = $_.Value }

    return New-Object PSCustomObject -Property @{ machine = $machineEnv; user = $userEnv; process = $processEnv }
}

function Restore-Environment($state)
{
    Write-Debug 'Restoring the environment'
    $state.machine.GetEnumerator() | ForEach-Object {
        $current = [Environment]::GetEnvironmentVariable($_.Key, 'Machine')
        if ($current -ne $_.Value) {
            Write-Warning "Restoring value of environment variable $($_.Key) at Machine scope. The need to do that means that some code did not use the environment manipulation functions *-EnvironmentVariable*."
            [Environment]::SetEnvironmentVariable($_.Key, $_.Value, 'Machine')
        }
    }

    $key = Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $key.GetValueNames() | Where-Object { -not $state.machine.ContainsKey($_) } | ForEach-Object {
        Write-Warning "Deleting environment variable $_ at Machine scope. The need to do that means that some code did not use the environment manipulation functions *-EnvironmentVariable*."
        [Environment]::SetEnvironmentVariable($_, $null, 'Machine')
    }

    $state.user.GetEnumerator() | ForEach-Object {
        $current = [Environment]::GetEnvironmentVariable($_.Key, 'User')
        if ($current -ne $_.Value) {
            Write-Warning "Restoring value of environment variable $($_.Key) at User scope. The need to do that means that some code did not use the environment manipulation functions *-EnvironmentVariable*."
            [Environment]::SetEnvironmentVariable($_.Key, $_.Value, 'User')
        }
    }

    $key = Get-Item 'HKCU:\Environment'
    $key.GetValueNames() | Where-Object { -not $state.user.ContainsKey($_) } | ForEach-Object {
        Write-Warning "Deleting environment variable $_ at User scope. The need to do that means that some code did not use the environment manipulation functions *-EnvironmentVariable*."
        [Environment]::SetEnvironmentVariable($_, $null, 'User')
    }

    $state.process.GetEnumerator() | ForEach-Object {
        $current = [Environment]::GetEnvironmentVariable($_.Key, 'Process')
        if ($current -ne $_.Value) {
            Write-Debug "Restoring value of environment variable $($_.Key) at Process scope"
            [Environment]::SetEnvironmentVariable($_.Key, $_.Value, 'Process')
        }
    }

    Get-ChildItem Env:\ | Select-Object -ExpandProperty Name | Where-Object { -not $state.process.ContainsKey($_) } | ForEach-Object {
        Write-Debug "Deleting environment variable $_ at Process scope"
        [Environment]::SetEnvironmentVariable($_, $null, 'Process')
    }
}

function Setup-EnvironmentMockup
{
    $global:ChocolateyTestEnvironmentVariables = Get-EnvironmentSnapshot
}

function Cleanup-EnvironmentMockup
{
    $global:ChocolateyTestEnvironmentVariables = $null
}

function Execute-WithEnvironmentProtection($scriptBlock)
{
    $savedEnvironment = Get-EnvironmentSnapshot
    try
    {
        Setup-EnvironmentMockup
        try
        {
            & $scriptBlock
        }
        finally
        {
            Cleanup-EnvironmentMockup
        }
    }
    finally
    {
        Restore-Environment $savedEnvironment
    }
}

function Add-EnvironmentVariable($name, $value, $targetScope)
{
    Write-Debug "Setting $name to $value at $targetScope scope"
    Set-EnvironmentVariable -Name $name -Value $Value -Scope $targetScope
    if ($targetScope -eq 'Process') {
        Write-Debug "Current $name value is '$value' (from Process scope)"
        return
    }
    # find lowest scope with $name set and use that value as current
    foreach ($currentScope in @('User', 'Machine')) {
        $valueAtCurrentScope = Get-EnvironmentVariable -Name $name -Scope $currentScope
        if ($valueAtCurrentScope -ne $null) {
            Write-Debug "Current $name value is '$valueAtCurrentScope' (from $currentScope scope)"
            Set-EnvironmentVariable -Name $name -Value $valueAtCurrentScope -Scope Process
            break
        }
    }
}

function Remove-EnvironmentVariable($name)
{
    Write-Debug "Ensuring environment variable $name is not set at any scope"
    'Machine','User','Process' | ForEach-Object {
        if (-not ([String]::IsNullOrEmpty((Get-EnvironmentVariable -Name $name -Scope $_)))) {
            Write-Debug "Deleting environment variable $name at $_ scope"
            Set-EnvironmentVariable -Name $name -Value $null -Scope $_
        }
    }
}

function Add-DirectoryToPath($directory, $scope)
{
    $curPath = Get-EnvironmentVariable -Name 'PATH' -Scope $scope
    $newPath = ($curPath -split ';' | Where-Object { $_.TrimEnd('\') -ne $directory.TrimEnd('\') }) -join ';'
    if ($newPath -ne $curPath) {
        Write-Debug "Directory $directory is already on PATH at $scope scope"
    } else {
        Write-Debug "Adding directory $directory to PATH at $scope scope"
        if ([String]::IsNullOrEmpty($newPath)) {
            Set-EnvironmentVariable -Name 'PATH' -Value $directory -Scope $scope
        } else {
            Set-EnvironmentVariable -Name 'PATH' -Value "$($newPath.TrimEnd(';'));$directory" -Scope $scope
        }
    }
    if ($scope -ne 'Process') {
        $curPath = Get-EnvironmentVariable -Name 'PATH' -Scope Process
        $newPath = ($curPath -split ';' | Where-Object { $_.TrimEnd('\') -ne $directory.TrimEnd('\') }) -join ';'
        if ($newPath -eq $curPath) {
            Write-Debug "Adding directory $directory to PATH at Process scope"
            if ([String]::IsNullOrEmpty($newPath)) {
                Set-EnvironmentVariable -Name 'PATH' -Value $directory -Scope Process
            } else {
                Set-EnvironmentVariable -Name 'PATH' -Value "$($newPath.TrimEnd(';'));$directory" -Scope Process
            }
        }
    }
}

function Remove-DirectoryFromPath($directory)
{
    Write-Debug "Ensuring directory $directory is not on PATH at any scope"
    'Machine','User','Process' | ForEach-Object {
        $scope = $_
        $curPath = Get-EnvironmentVariable -Name 'PATH' -Scope $scope
        $newPath = ($curPath -split ';' | Where-Object { $_.TrimEnd('\') -ne $directory.TrimEnd('\') }) -join ';'
        if ($newPath -ne $curPath) {
            Write-Debug "Removing directory $directory from PATH at $scope scope"
            Set-EnvironmentVariable -Name 'PATH' -Value $newPath -Scope $scope
        }
    }
}

function Assert-OnPath($directory, $pathScope)
{
    $path = Get-EnvironmentVariable -Name 'PATH' -Scope $pathScope
    $dirInPath = $path -split ';' | Where-Object { $_ -eq $directory }
    "$dirInPath" | Should not BeNullOrEmpty
}

function Assert-NotOnPath($directory, $pathScope)
{
    $path = Get-EnvironmentVariable -Name 'PATH' -Scope $pathScope
    $dirInPath = $path -split ';' | Where-Object { $_ -eq $directory }
    "$dirInPath" | Should BeNullOrEmpty
}
