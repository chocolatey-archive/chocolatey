function Chocolatey-Update {
param(
  [string] $packageName ='',
  [string] $source = ''
)
  Write-Debug "Running 'Chocolatey-Update' for '$packageName' with source:`'$source`'.";

  if ($packageName -eq 'all') {
    Write-Host "Chocolatey is going to determine all packages available for an update. You may not see any output for awhile..."
  }

  $updated = $false
  $versions = Chocolatey-Version $packageName $source
  foreach ($version in $versions) {
    if ($version -ne $null -and (($version.'foundCompare' -lt $version.'latestCompare') -or ($force -and $versions.'foundCompare' -eq $versions.'latestCompare'))) {
        Write-Host "Updating $($version.name) from $($version.found) to $($version.latest)"
        Chocolatey-NuGet $version.name $source
        $updated = $true
    } else {
      Write-Debug "$($version.name) - you have either a newer version or the same version already available"
    }
  }

  if (! $updated) {
    Write-Host "Nothing to update."
  }
}
