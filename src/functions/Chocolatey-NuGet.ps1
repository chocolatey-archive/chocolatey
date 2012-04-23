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
Chocolatey ($chocVer) is installing $packageName (from $srcArgs) to "$nugetLibPath"
$h1
Package License Acceptance Terms
$h2
Please run chocolatey /? for full license acceptance verbage. By installing you accept the license for the package you are installing...
$h2
"@ | Write-Host

  $nugetOutput = Run-NuGet $packageName $source $version

  foreach ($line in $nugetOutput) {
    if ($line -notlike "*not installed*" -and ($line -notlike "*already installed." -or $force -eq $true) -and $line -notlike "Attempting to resolve dependency*") {
      $installedPackageName = ''
      $installedPackageVersion = ''
    
      $regex = [regex]"'[.\S]+\s?"
      $pkgNameMatches = $regex.Matches($line) | select -First 1 
      if ($pkgNameMatches -ne $null) {
        $installedPackageName = $pkgNameMatches -replace "'", "" -replace " ", ""
      }
      
      $regex = [regex]"[0-9.]+[[)]?'"
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
$h2
Chocolatey Runner ($($installedPackageName.ToUpper()))
$h2
"@ | Write-Host

          if ([System.IO.Directory]::Exists($packageFolder)) {
            Delete-ExistingErrorLog $installedPackageName
            Run-ChocolateyPS1 $packageFolder $installedPackageName $installerArguments
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