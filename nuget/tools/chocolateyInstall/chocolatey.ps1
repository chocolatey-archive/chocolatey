param($command,$packageName='',$source='https://go.microsoft.com/fwlink/?LinkID=206669',$version='')#todo:,[switch] $silent)
# chocolatey
# Copyright (c) 2011 Rob Reynolds
# Crediting contributions by Chris Ortman, Nekresh, Staxmanade
# Big thanks to Keith Dahlby for all the powershell help! 
# Apache License, Version 2.0 - http://www.apache.org/licenses/LICENSE-2.0


#Let's get Chocolatey!
$chocVer = '0.9.8.4'
$nugetChocolateyPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
$nugetPath = (Split-Path -Parent $nugetChocolateyPath)
$nugetExePath = Join-Path $nuGetPath 'bin'
$nugetLibPath = Join-Path $nuGetPath 'lib'

$nugetExe = Join-Path $nugetChocolateyPath 'nuget.exe'
$h1 = '====================================================='
$h2 = '-------------------------'

function Run-ChocolateyProcess {
param([string]$file, [string]$arguments = $args, [switch] $elevated);
	
	Write-Host "Running $file $arguments. This may take awhile and permissions may need to be elevated, depending on the package.";
  $psi = new-object System.Diagnostics.ProcessStartInfo $file;
  $psi.Arguments = $arguments;
	#$psi.Verb = "runas";
	#	$psi.CreateNoWindow = $true
	#	$psi.RedirectStandardOutput = $true;
	#	$psi.RedirectStandardError = $true;
	#	$psi.UseShellExecute = $false;
  $psi.WorkingDirectory = get-location;
 
  $s = [System.Diagnostics.Process]::Start($psi);
  $s.WaitForExit();
  if ($s.ExitCode -ne 0) {
    Write-Host "[ERROR] Running $file with $arguments was not successful." -ForegroundColor White -BackgroundColor DarkRed
  }
}

function Chocolatey-NuGet { 
param([string] $packageName, $source = 'https://go.microsoft.com/fwlink/?LinkID=206669')

@"
$h1
Chocolatey ($chocVer) is installing $packageName (from $source) to "$nugetLibPath"
$h1
Package License Acceptance Terms
$h2
Please run chocolatey /? for full license acceptance verbage. By installing you accept the license for the package you are installing...
$h2
"@ | Write-Host

	$nugetOutput = Run-NuGet $packageName $source $version
	
	foreach ($line in $nugetOutput) {
		if ($line -notlike "*not installed*" -and $line -notlike "Dependency*already installed." -and $line -notlike "Attempting to resolve dependency*") {
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
            Run-ChocolateyPS1 $packageFolder $installedPackageName
            Get-ChocolateyBins $packageFolder
          }
        }
      }
    }
  }
  
@"
$h1
Chocolatey has finished installing $packageName
$h1
"@ | Write-Host
}

function Delete-ExistingErrorLog {
param([string] $packageName)
  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "$packageName"
  $failureLog = Join-Path $tempDir 'failure.log'
  if ([System.IO.File]::Exists($failureLog)) {
    [System.IO.File]::Delete($failureLog)
  }
}

function Run-NuGet {
param([string] $packageName, $source = 'https://go.microsoft.com/fwlink/?LinkID=206669',$version = '')
@"
$h2
NuGet
$h2
"@ | Write-Host

	#todo: If package name is non-existent or is set to all, it means we are going to update all currently installed packages.
  $packageArgs = "install $packageName /outputdirectory `"$nugetLibPath`" /source $source"
  if ($version -notlike '') {
    $packageArgs = $packageArgs + " /version $version";
  }
  $logFile = Join-Path $nugetChocolateyPath 'install.log'
	$errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile
	
  $nugetOutput = Get-Content $logFile -Encoding Ascii
	foreach ($line in $nugetOutput) {
    Write-Host $line
  }
	$errors = Get-Content $errorLogFile
	if ($errors -ne '') {
		Write-Host $errors -BackgroundColor Red -ForegroundColor White
		#throw $errors
	}
	
	return $nugetOutput
}

function Run-ChocolateyPS1 {
param([string] $packageFolder, [string] $packageName)
  if ($packageFolder -notlike '') { 
@"
$h2
Chocolatey Installation (chocolateyinstall.ps1)
$h2
Looking for chocolateyinstall.ps1 in folder $packageFolder
If chocolateyInstall.ps1 is found, it will be run.
$h2
"@ | Write-Host

    $ps1 = Get-ChildItem  $packageFolder -recurse | ?{$_.name -match "chocolateyinstall.ps1"} | sort name -Descending | select -First 1
    
    if ($ps1 -notlike '') {
      $ps1FullPath = $ps1.FullName
      $importChocolateyHelpers = "";
      Get-ChildItem "$nugetChocolateyPath\helpers" -Filter *.psm1 | ForEach-Object { $importChocolateyHelpers = "& import-module -name  $($_.FullName);$importChocolateyHelpers" };
      Run-ChocolateyProcess powershell "-NoProfile -ExecutionPolicy unrestricted -Command `"$importChocolateyHelpers . `'$ps1FullPath`'`"" -elevated
      #testing Start-Process -FilePath "powershell.exe" -ArgumentList " -noexit `"$ps1FullPath`"" -Verb "runas"  -Wait  #-PassThru -UseNewEnvironment #-RedirectStandardError $errorLog -WindowStyle Normal
      
      #detect errors
      $chocTempDir = Join-Path $env:TEMP "chocolatey"
      $tempDir = Join-Path $chocTempDir "$packageName"
      $failureLog = Join-Path $tempDir 'failure.log'
      if ([System.IO.File]::Exists($failureLog)) {
        #we have issues, time to throw an error
        $errorContents = Get-Content $failureLog
        if ($errorContents -ne '') {
          foreach ($errorLine in $errorContents) {
            Write-Host $errorLine -BackgroundColor Red -ForegroundColor White
          }
          throw $errorContents
        }
      }
    }
  }
}

function Get-ChocolateyBins {
param([string] $packageFolder)
  if ($packageFolder -notlike '') { 
@"
$h2
Executable Batch Links
$h2
Looking for executables in folder: $packageFolder
Adding batch files for any executables found to a location on PATH.
In other words, the executable will be available from ANY command line/powershell prompt.
$h2
"@ | Write-Host
    try {
      $files = get-childitem $packageFolder -include *.exe -recurse
      foreach ($file in $files) {
        Generate-BinFile $file.Name.Replace(".exe","") $file.FullName
      }
    }
    catch {
      Write-Host 'There are no executables in the package. You may not need this as a #chocolatey #nuget. A vanilla #nuget may suffice.'
    }
    Write-Host "$h2"
  }
}

function Generate-BinFile {
param([string] $name, [string] $path)
  $packageBatchFileName = Join-Path $nugetExePath "$name.bat"
	Write-Host "Adding $packageBatchFileName and pointing to $path"
"@echo off
""$path"" %*" | Out-File $packageBatchFileName -encoding ASCII 
}

function Chocolatey-Update {
param([string] $packageName ='', $source = 'https://go.microsoft.com/fwlink/?LinkID=206669')

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  
  $packages = $packageName
  if ($packageName -eq 'all') {
		$packageFolders = Get-ChildItem $nugetLibPath | sort name
		$packages = $packageFolders -replace "(\.\d{1,})+"|gu 
	}

	foreach ($package in $packages) {
		$versions = Chocolatey-Version $package $source
		if ($versions -ne $null -and $versions.'found' -lt $versions.'latest') {
			Chocolatey-NuGet $package $source
		}
	}
}

function Chocolatey-Help {
@"
$h1
Chocolatey - Your local machine NuGet repository AKA your local tools repository  AKA apt-get for Windows
Version: `'$chocVer'`
Install Directory: `'$nugetPath`'
$h1
Chocolatey allows you to install application nuggets and run executables from anywhere.
$h2
Known Issues
$h2
 * There is no automated uninstallation.
$h2
Release Notes
$h2
v0.9.1 
 * Shortcut for 'chocolatey install' - 'cinst' now available.
v0.9.2
 * List command added.	
v0.9.3 
 * You can now pass -source and -version to install command
v0.9.4 
 * List command has a filter.
 * Package license acceptance terms notated
v0.9.5 
 * Helper for native installer added (Install-ChocolateyPackage). Reduces the amount of powershell necessary to download and install a native package to two lines from over 25.
 * Helper outputs progress during download.
 * Dependency runner is complete
v0.9.6
 * Can execute powershell and chocolatey without having to change execution rights to powershell system wide.
 * New Helper added - Get-ChocolateyWebFile - downloads a file from a url and gives you back the location of the file once complete.
 * New Helper added - Get-ChocolateyZipContents - unzips a file to a directory of your choosing.
 * .1 - Adding in ability to find a dependency when the version doesn't exist.
 * .2 - Addressed a small bug in getting back the file name from the helper
 * .3 - New Helper added Install-ChocolateyZipPackage - this wraps the two upper commands into one smaller command and addresses the file name bug
 * .4 - remove timeout
v0.9.7
 * New helper added Install-ChocolateyInstallPackage - this was previously part of the download & install and has been broken out.
 * The powershell module is automatically loaded, so packages no longer need to import the module. This means one line chocolateyInstall.ps1 files!
 * Error handling is improved.
 * Silent installer override for msi has been removed to allow for additional arguments that need to be passed.
 * New chocolatey command! Version allows you to see if a package you have installed is the most up to date. Leave out package and it will check for chocolatey itself.
 * .1 - Fixing an introduced bug where the downloader didn't get the file name passed to it.
 * .2 - Fixing an underlying issue with not having silent arguments for exe files. 
 * .3 - Fixing Install-ChocolateyZipPackage so that it works again.
v0.9.8
 * Shortcuts have been added: 'cup' for 'chocolatey update', 'cver' for 'chocolatey version', and 'clist' for 'chocolatey list'.
 * Update only runs if newer version detected.
 * Calling update with no arguments will update chocolatey.
 * Calling update with all will update your entire chocolatey repository.
 * A dependency will not reinstall once it has been installed. To have it reinstall, you can install it directly (or delete it from the repository and run the core package).
 * .1 - general fix to bad character in file. Fixed selection for update as well
 * .2 - You now have the option of a custom installation folder. Thanks Jason Jarrett!
 * .3
  - NuGet updated to v1.4
  - New chocolatey command! InstallMissing allows you to install a package only if it is not already installed. Shortcut is 'cinstm'.
  - Much of the error handling is improved. There are two new Helpers to call (ChocolateySuccess and Write-ChocolateyFailure).
	- New Helper! Install-ChocolateyPath - give it a path for out of band items that are not imported to path with chocolatey 
	- New Helper! Start-ChocolateyProcessAsAdmin - this allows you to run processes as administrator
	- New Helper! Install-ChocolateyDesktopLink - put shortcuts on the desktop
 * .4
  - Fixing a small issue with the Install-ChocolateyDesktopLink
$h2
$h2
using (var legalese = new LawyerText()) {
$h2
Package License Acceptance Terms
$h2
The act of running chocolatey to install a package constitutes acceptance of the license for the application, executable(s), or other artifacts that are brought to your machine as a result of a chocolatey install.
This acceptance occurs whether you know the license terms or not. It is suggested that you read and understand the license terms of any package you plan to install prior to installation through chocolatey.
If you do not accept the license of a package you are installing, please uninstall it and any artifacts that end up on your machine as a result of the install.
$h2
Waiver of Responsibility
$h2
The use of chocolatey means that an individual using chocolatey assumes the responsibility for any changes (including any damages of any sort) that occur to the system as a result of using chocolatey. 
This does not supercede the verbage or enforcement of the license for chocolatey (currently Apache 2.0), it is only noted here that you are waiving any rights to collect damages by your use of chocolatey. 
It is recommended you read the license (http://www.apache.org/licenses/LICENSE-2.0) to gain a full understanding (especially section 8. Limitation of Liability) prior to using chocolatey.
$h2
}
$h2
$h2
Usage
$h2
chocolatey [install packageName [-source source] [-version version]  | installmissing packageName [-source source] | update packageName [-source source] [-version version] | list [packageName] [-source source] | help | version [packageName]]

example: chocolatey install nunit
example: chocolatey install nunit -version 2.5.7.10213
example: chocolatey installmissing nunit
example: chocolatey update nunit -source http://somelocalfeed.com/nuget/
example: chocolatey help
example: chocolatey list (might take awhile)
example: chocolatey list nunit
example: chocolatey version
example: chocolatey version nunit

A shortcut to 'chocolatey install' is 'cinst'
cinst packageName  [-source source] [-version version]
example: cinst 7zip
example: cinst ruby -version 1.8.7
$h1
"@ | Write-Host
}

function Chocolatey-List {
  param([string]$selector='', [string]$source='https://go.microsoft.com/fwlink/?LinkID=206669');
  
  $parameters = "list /source $source"
  
  if ($selector -ne '') {
	$parameters = "$parameters ""$selector"""
  }
  
  Start-Process $nugetExe -ArgumentList $parameters -NoNewWindow -Wait 
}

function Chocolatey-Version {
param([string]$packageName='',[string]$source='https://go.microsoft.com/fwlink/?LinkID=206669')
  if ($packageName -eq '') {$packageName = 'chocolatey';}
  
  $packages = $packageName
  if ($packageName -eq 'all') {
    $packageFolders = Get-ChildItem $nugetLibPath | sort name
    $packages = $packageFolders -replace "(\.\d{1,})+"|gu 
  }
  
  foreach ($package in $packages) {
    $logFile = Join-Path $nugetChocolateyPath 'list.log'
    Start-Process $nugetExe -ArgumentList "list /source $source ""$package""" -NoNewWindow -Wait -RedirectStandardOutput $logFile
    Start-Sleep 1 #let it finish writing to the config file

    $versionLatest = Get-Content $logFile | ?{$_ -match "^$package\s+\d+"} | sort $_ -Descending | select -First 1 
    $versionLatest = $versionLatest -replace "$package ", "";

    $versionFound = $chocVer
    if ($packageName -ne 'chocolatey') {
      $versionFound = 'no version'
      $packageFolder = Get-ChildItem $nugetLibPath | ?{$_.name -match "^$package.*"} | sort name -Descending | select -First 1 

      if ($packageFolder -notlike '') { 
        #Write-Host $packageFolder
        $versionFound = $packageFolder.Name -replace "$package\."
      }
    }
  
    $verMessage = "The most recent version of $package available from ($source) is $versionLatest. On your machine you have $versionFound installed."
    if ($versionLatest -eq $versionFound) { 
      $verMessage = "You have the latest version of $package ($versionLatest) based on ($source)."
    }
    if ($versionLatest -lt $versionFound) {
      $verMessage = "$verMessage You must be smarter than the average bear..."
    }
    if ($versionLatest -eq '') {
      $verMessage = "$package does not appear to be on ($source). You have $versionFound installed. Interesting..."
    }
    Write-Host $verMessage
  }
  
	$versions = @{latest = $versionLatest; found = $versionFound }
	return $versions
}

function Chocolatey-InstallIfMissing {
param([string] $packageName, $source = 'https://go.microsoft.com/fwlink/?LinkID=206669',$version = '')
  
  $versions = Chocolatey-Version $packageName $source
  
  if ($versions.'found' -contains 'no version' -or ($version -ne '' -and $versions.'found' -ne $version)) {
    Chocolatey-NuGet $packageName $source $version
  }
}

#main entry point
switch -wildcard ($command) 
{
  "install" { Chocolatey-NuGet  $packageName $source $version; }
  "installmissing" { Chocolatey-InstallIfMissing $packageName $source $version; }
  "update" { Chocolatey-Update $packageName $source; }
  "list" { Chocolatey-List $packageName $source; }
  "version" { Chocolatey-Version $packageName $source; }
  default { Chocolatey-Help; }
}
