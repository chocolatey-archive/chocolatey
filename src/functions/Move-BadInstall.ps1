function Move-BadInstall {
param(
  [string] $packageName,  
  [string] $version = '',
  [string] $packageFolder = ''
)
  Write-Debug "Running 'Move-BadInstall' for $packageName version: `'$version`', packageFolder:`'$packageFolder`'";

  #copy the bad stuff to a temp directory
  $badPackageFolder = $badLibPath #Join-Path $badLibPath "$($installedPackageName).$($installedPackageVersion)"
  try {
    if ([System.IO.Directory]::Exists($badPackageFolder)) {
      [System.IO.Directory]::Delete($badPackageFolder,$true) #| out-null
    }
    [System.IO.Directory]::CreateDirectory($badPackageFolder) | out-null
    
    write-debug "Moving bad package `'$packageName v$version`' to `'$badPackageFolder`'."
    #Get-Childitem "$badPackageFolder" -recurse | remove-item
    Move-Item $packageFolder $badPackageFolder -force #| out-null
  } catch {
    Write-Error "Could not move bad package $packageName from `'$packageFolder`' to `'$badPackageFolder`': $($_.Exception.Message)"
  }

}