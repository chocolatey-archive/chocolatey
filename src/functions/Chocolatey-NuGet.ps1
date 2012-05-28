function Chocolatey-NuGet { 
param(
  [string] $packageName,
  [string] $source = 'https://go.microsoft.com/fwlink/?LinkID=230477'
)

  if ($packageName -eq 'all') { 
    Chocolatey-InstallAll $source
    return
  }

  $srcArgs = "$source"
  if ($source -like 'https://go.microsoft.com/fwlink/?LinkID=230477') {
    $srcArgs = "http://chocolatey.org/api/v2/ OR $source"
  }

@"
$h1
Chocolatey ($chocVer) is installing $packageName (from $srcArgs) to "$nugetLibPath". By installing you accept the license for the package you are installing (please run chocolatey /? for full license acceptance terms).
$h1
"@ | Write-Host

  $nugetOutput = Run-NuGet $packageName $source $version

  foreach ($line in $nugetOutput) {
    if ($line -like "*already installed." -and $force -eq $false) {
      Write-Host "$line - If you want to reinstall the current version of an existing package, please use the -force command."
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
@"
$h2
Chocolatey Runner ($($installedPackageName.ToUpper()))
$h2
"@ | Write-Host

          if ([System.IO.Directory]::Exists($packageFolder)) {
            Delete-ExistingErrorLog $installedPackageName
            Run-ChocolateyPS1 $packageFolder $installedPackageName $installerArguments "install"
            Get-ChocolateyBins $packageFolder
          }
        }
      }
    }
  }
  
@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}