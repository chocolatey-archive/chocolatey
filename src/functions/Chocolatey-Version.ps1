function Chocolatey-Version {
param(
  [string] $packageName='',
  [string] $source=''
)

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  Write-Debug "Running 'Chocolatey-Version' for $packageName with source:`'$source`'.";

  $packages = @{}

  if ($packageName -eq 'all') {
    Write-Debug "Reading all packages in $nugetLibPath"
    $packageName = ''
  }

  if ($packageName -eq 'chocolatey') {
    Write-Debug "Getting $packageName from returned list"
    $packages.Add("$packageName","$chocVer")
  } else {
    Write-Debug "Getting local packages based on all or passed in package name"
    $packages = Chocolatey-List -selector "$packageName" -source "$nugetLibPath" -returnOutput
  }

  if ($packageName -ne '') {
    Write-Debug "Getting $packageName from returned local list"
    $package = $packages.GetEnumerator() | ?{$_.Name -eq $packageName} | Select-Object
    $packages.Clear()
    $packages.Add("$($package.Name)","$($package.Value)")
  }

  $versionFound = ''
  $versionsObj = New-Object –typename PSObject
  foreach ($package in $packages.GetEnumerator()) {
    $packageName = $package.Name
    if ($packageName -eq '') { continue }
    $versionFound = $package.Value

    if (!$localOnly) {
      $remotePackages = Chocolatey-List -selector "$packageName" -source "$source" -returnOutput
      Write-Debug "Getting $packageName from returned remote list"
      $remotePackage = $remotePackages.GetEnumerator() | ?{$_.Name -eq $packageName} | Select-Object

      $versionLatest = ''
      if ($remotePackage -ne $null) {
        $versionLatest = $remotePackage.Value
      }

      #todo - make this compare prerelease information as well
      $versionLatestCompare = Get-LongPackageVersion $versionLatest

      $versionFoundCompare = ''
      if ($versionFound -ne 'no version') {
        $versionFoundCompare = Get-LongPackageVersion $versionFound
      }

      $verMessage = "A more recent version is available"
      if ($versionLatestCompare -eq $versionFoundCompare) {
          $verMessage = "Latest version installed"
      }
      if ($versionLatestCompare -lt $versionFoundCompare) {
          $verMessage = "Your version is newer than the most recent. You must be smarter than the average bear..."
      }
      if ($versionLatest -eq '') {
          $verMessage = "$package does not appear to be on the source(s) specified: "
      }

      $versions = @{name=$($package.Name); latest = $versionLatest; found = $versionFound; latestCompare = $versionLatestCompare; foundCompare = $versionFoundCompare; verMessage = $verMessage}
      $versionsObj = New-Object –typename PSObject -Property $versions
      $versionsObj
    } else {
      $versions = @{name=$($package.Name); found = $versionFound}
      $versionsObj = New-Object –typename PSObject -Property $versions
      $versionsObj
    }
  }

  # exit error 1 if querying a single package, it is not installed, and not called from another function (ie cup)
  $commandType=((Get-Variable -Name MyInvocation -Scope 1 -ValueOnly).MyCommand).CommandType
  if ($packages.Count -eq 1 -and $versionFound -eq '' -and $commandType -ne 'Function') {
    throw "No package found"
  }
}
