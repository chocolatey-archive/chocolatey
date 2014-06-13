function Backup-Environment()
{
    Write-Debug 'Backing up the environment'
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
            Write-Debug "Restoring value of environment variable $($_.Key) at Machine scope"
            [Environment]::SetEnvironmentVariable($_.Key, $_.Value, 'Machine')
        }
    }

    $key = Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $key.GetValueNames() | Where-Object { -not $state.machine.ContainsKey($_) } | ForEach-Object {
        Write-Debug "Deleting environment variable $_ at Machine scope"
        [Environment]::SetEnvironmentVariable($_, $null, 'Machine')
    }

    $state.user.GetEnumerator() | ForEach-Object {
        $current = [Environment]::GetEnvironmentVariable($_.Key, 'User')
        if ($current -ne $_.Value) {
            Write-Debug "Restoring value of environment variable $($_.Key) at User scope"
            [Environment]::SetEnvironmentVariable($_.Key, $_.Value, 'User')
        }
    }

    $key = Get-Item 'HKCU:\Environment'
    $key.GetValueNames() | Where-Object { -not $state.user.ContainsKey($_) } | ForEach-Object {
        Write-Debug "Deleting environment variable $_ at User scope"
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

function Execute-WithEnvironmentBackup($scriptBlock)
{
    $savedEnvironment = Backup-Environment
    try
    {
        & $scriptBlock
    }
    finally
    {
        Restore-Environment $savedEnvironment
    }
}

function Add-EnvironmentVariable($name, $value, $targetScope)
{
    Write-Debug "Setting $name to $value at $targetScope scope"
    [Environment]::SetEnvironmentVariable($name, $value, $targetScope)
    if ($targetScope -eq 'Process') {
        Write-Debug "Current $name value is '$value' (from Process scope)"
        return
    }
    # find lowest scope with $name set and use that value as current
    foreach ($currentScope in @('User', 'Machine')) {
        $valueAtCurrentScope = [Environment]::GetEnvironmentVariable($name, $currentScope)
        if ($valueAtCurrentScope -ne $null) {
            Write-Debug "Current $name value is '$valueAtCurrentScope' (from $currentScope scope)"
            [Environment]::SetEnvironmentVariable($name, $valueAtCurrentScope, 'Process')
            break
        }
    }
}

function Remove-EnvironmentVariable($name)
{
    Write-Debug "Ensuring environment variable $name is not set at any scope"
    'Machine','User','Process' | ForEach-Object {
        if (-not ([String]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name, $_)))) {
            Write-Debug "Deleting environment variable $name at $_ scope"
            [Environment]::SetEnvironmentVariable($name, $null, $_)
        }
    }
}

function Add-DirectoryToPath($directory, $scope)
{
    $curPath = [Environment]::GetEnvironmentVariable('PATH', $scope)
    $newPath = ($curPath -split ';' | Where-Object { $_.TrimEnd('\') -ne $directory.TrimEnd('\') }) -join ';'
    if ($newPath -ne $curPath) {
        Write-Debug "Directory $directory is already on PATH at $scope scope"
    } else {
        Write-Debug "Adding directory $directory to PATH at $scope scope"
        if ([String]::IsNullOrEmpty($newPath)) {
            [Environment]::SetEnvironmentVariable('PATH', $directory, $scope)
        } else {
            [Environment]::SetEnvironmentVariable('PATH', "$($newPath.TrimEnd(';'));$directory", $scope)
        }
    }
    if ($scope -ne 'Process') {
        $curPath = [Environment]::GetEnvironmentVariable('PATH', 'Process')
        $newPath = ($curPath -split ';' | Where-Object { $_.TrimEnd('\') -ne $directory.TrimEnd('\') }) -join ';'
        if ($newPath -eq $curPath) {
            Write-Debug "Adding directory $directory to PATH at Process scope"
            if ([String]::IsNullOrEmpty($newPath)) {
                [Environment]::SetEnvironmentVariable('PATH', $directory, 'Process')
            } else {
                [Environment]::SetEnvironmentVariable('PATH', "$($newPath.TrimEnd(';'));$directory", 'Process')
            }
        }
    }
}

function Remove-DirectoryFromPath($directory)
{
    Write-Debug "Ensuring directory $directory is not on PATH at any scope"
    'Machine','User','Process' | ForEach-Object {
        $scope = $_
        $curPath = [Environment]::GetEnvironmentVariable('PATH', $scope)
        $newPath = ($curPath -split ';' | Where-Object { $_.TrimEnd('\') -ne $directory.TrimEnd('\') }) -join ';'
        if ($newPath -ne $curPath) {
            Write-Debug "Removing directory $directory from PATH at $scope scope"
            [Environment]::SetEnvironmentVariable('PATH', $newPath, $scope)
        }
    }
}

function Assert-OnPath($directory, $pathScope)
{
    $path = [Environment]::GetEnvironmentVariable('PATH', $pathScope)
    $dirInPath = [Environment]::GetEnvironmentVariable('PATH', $pathScope) -split ';' | Where-Object { $_ -eq $directory }
    "$dirInPath" | Should not BeNullOrEmpty
}

function Assert-NotOnPath($directory, $pathScope)
{
    $path = [Environment]::GetEnvironmentVariable('PATH', $pathScope)
    $dirInPath = [Environment]::GetEnvironmentVariable('PATH', $pathScope) -split ';' | Where-Object { $_ -eq $directory }
    "$dirInPath" | Should BeNullOrEmpty
}
