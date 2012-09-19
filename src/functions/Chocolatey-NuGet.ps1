function Chocolatey-NuGet { 
param(
  [string] $packageName,
  [string] $source = ''
)
  Write-Debug "Running 'Chocolatey-NuGet' for $packageName with source:`'$source`'";

  if ($packageName -eq 'all') { 
    Chocolatey-InstallAll $source
    return
  }

  $srcArgs = ""
  if ($source -ne '') {
    $srcArgs = "(from $source)"
  }

Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies. By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black
Write-Debug "Installing packages to `"$nugetLibPath`"."

  $nugetOutput = (Run-NuGet $packageName $source $version).Split("`n")

  foreach ($line in $nugetOutput) {
    Write-Debug "Evaluating NuGet output for line: $line"

    if ($line -like "*already installed." -and $force -eq $false) {
      Write-Host "$line - If you want to reinstall the current version of an existing package, please use the -force command." -ForegroundColor $Warning -BackgroundColor Black
      Write-Host ""
    }
    if ($line -notlike "*not installed*" -and ($line -notlike "*already installed." -or $force -eq $true) -and $line -notlike "Attempting to resolve dependency*") {
      $installedPackageName = ''
      $installedPackageVersion = ''
    
      $regex = [regex]"'[.\S]+\s?"
      $pkgNameMatches = $regex.Matches($line) | select -First 1 
      if ($pkgNameMatches -ne $null) {
        $installedPackageName = $pkgNameMatches -replace "'", "" -replace " ", ""
      }
      
      $regex = [regex]"[\d\.]+[\-\w]*[[)]?'"
      $pkgVersionMatches = $regex.Matches($line) | select -First 1 
      if ($pkgVersionMatches -ne $null) {
        $installedPackageVersion = $pkgVersionMatches -replace '\)', '' -replace "'", "" -replace " ", ""
      }
      
      if ($installedPackageName -eq '') {
        $regex = [regex]"`"[.\S]+\s?"
        $pkgNameMatches = $regex.Matches($line) | select -First 1
        $installedPackageName = $pkgNameMatches -replace "`"", "" -replace " ", ""
        $installedPackageVersion = $version
      }
      
      if ($installedPackageName -ne '') {
        $packageFolder = ''
        if ($installedPackageVersion -ne '') {
          $packageFolder = Join-Path $nugetLibPath "$($installedPackageName).$($installedPackageVersion)" 
        } else {
          #search the lib directory for the highest number of the folder        
          $packageFolder = Get-ChildItem $nugetLibPath | ?{$_.name -match "^$installedPackageName*"} | sort name -Descending | select -First 1 
          $packageFolder = $packageFolder.FullName
        }
        
        if ($packageFolder -ne '') {

          Write-Host "______ $installedPackageName v$installedPackageVersion ______" -ForegroundColor $RunNote -BackgroundColor Black

          if ([System.IO.Directory]::Exists($packageFolder)) {
            Delete-ExistingErrorLog $installedPackageName
            Run-ChocolateyPS1 $packageFolder $installedPackageName $installerArguments "install"
            Get-ChocolateyBins $packageFolder
            if ($installedPackageName.ToLower().EndsWith('.extension')) {
              Chocolatey-InstallExtension $packageFolder $installedPackageName
            }
          }
        }
      }
    }
  }
 
 Update-SessionEnvironment
 Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
}