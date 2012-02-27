param(
  [string]$command,
  [string]$packageName='',
  [string]$source='https://go.microsoft.com/fwlink/?LinkID=230477',
  [string]$version='',
  [alias("all")][switch] $allVersions = $false,
  [alias("ia","installArgs")][string] $installArguments = '',
  [alias("o","override","overrideArguments","notSilent")]
  [switch] $overrideArgs = $false,
  [switch] $force = $false,
  [alias("pre")][switch] $prerelease = $false
) 
# chocolatey
# Copyright (c) 2011-Present Rob Reynolds
# Crediting contributions by Chris Ortman, Nekresh, Staxmanade, Chrissie1, AnthonyMastrean
# Big thanks to Keith Dahlby for all the powershell help! 
# Apache License, Version 2.0 - http://www.apache.org/licenses/LICENSE-2.0

## Set the culture to invariant
$currentThread = [System.Threading.Thread]::CurrentThread;
$culture = [System.Globalization.CultureInfo]::InvariantCulture;
$currentThread.CurrentCulture = $culture;
$currentThread.CurrentUICulture = $culture;

#Let's get Chocolatey!
$chocVer = '0.9.8.16'
$nugetChocolateyPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
$nugetPath = (Split-Path -Parent $nugetChocolateyPath)
$nugetExePath = Join-Path $nuGetPath 'bin'
$nugetLibPath = Join-Path $nuGetPath 'lib'
$chocInstallVariableName = "ChocolateyInstall"

$nugetExe = Join-Path $nugetChocolateyPath 'nuget.exe'
$h1 = '====================================================='
$h2 = '-------------------------'

# grab functions from files
Resolve-Path $nugetChocolateyPath\functions\*.ps1 | 
    ? { -not ($_.ProviderPath.Contains(".Tests.")) } |
    % { . $_.ProviderPath }

function Run-ChocolateyProcess {
param(
  [string]$file, 
  [string]$arguments = $args, 
  [switch] $elevated
)
	
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

function Chocolatey-Install {
param(
  [string] $packageName, 
  $source = 'https://go.microsoft.com/fwlink/?LinkID=230477', 
  [string] $version = '',
  [string] $installerArguments = ''
)
  
  if($($packageName).EndsWith('.config')) {
    Chocolatey-PackagesConfig $packageName
    return
  }
  
  switch -wildcard ($source) 
  {
    "webpi" { Chocolatey-WebPI $packageName $installerArguments; }
    "ruby" { Chocolatey-RubyGem $packageName $version $installerArguments; }
    default { Chocolatey-NuGet $packageName $source $version; }
  }
}

function Chocolatey-PackagesConfig {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $packagesConfigPath
)

  if(-not(Test-Path $packagesConfigPath)) {
    if (-not($($packagesConfigPath).Contains('\'))) {
      Chocolatey-NuGet $packagesConfigPath
    }
    
    return
  }
  
  $h1
  "Installing packages from manifest: '$(Resolve-Path $packagesConfigPath)'"
  $h1
  
  $xml = [xml] (Get-Content $packagesConfigPath)
  $xml.packages.package | ?{ $_.id -ne '' -and $_.id -ne $null} | %{
    Chocolatey-Install -packageName $_.id -source $_.source -version $_.version
  }
}

function Chocolatey-NuGet { 
param(
  [string] $packageName,
  [string]$source = 'https://go.microsoft.com/fwlink/?LinkID=230477'
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
param(
  [string] $packageName, 
  $source = 'https://go.microsoft.com/fwlink/?LinkID=230477',
  $version = ''
)
@"
$h2
NuGet
$h2
"@ | Write-Host

  $srcArgs = "-Source `"$source`""
  if ($source -like 'https://go.microsoft.com/fwlink/?LinkID=230477') {
    $srcArgs = "-Source `"http://chocolatey.org/api/v2/`" -Source `"$source`""
  }

  $packageArgs = "install $packageName -Outputdirectory `"$nugetLibPath`" $srcArgs"
  if ($version -notlike '') {
    $packageArgs = $packageArgs + " -Version $version";
  }
  
  if ($prerelease -eq $true) {
    $packageArgs = $packageArgs + " -Prerelease";
  }
  $logFile = Join-Path $nugetChocolateyPath 'install.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  #write-host "TEMP: NuGet Args - $packageArgs"
  Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    Write-Host $line
  }
  $errors = Get-Content $errorLogFile
  if ($errors -ne '') {
    Write-Host $errors -BackgroundColor Red -ForegroundColor White
    #Throw $errors
  }
  
  if (($nugetOutput -eq '' -or $nugetOutput -eq $null) -and ($errors -eq '' -or $errors -eq $null)) {
    $noExecution = 'Execution of NuGet not detected. Please make sure you have .NET Framework 4.0 installed.'
    #write-host  -BackgroundColor Red -ForegroundColor White
    Throw $noExecution
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
      $env:chocolateyInstallArguments = "$installArguments"
      $env:chocolateyInstallOverride = $null
      if ($overrideArgs -eq $true) {
        $env:chocolateyInstallOverride = $true
      } 
      
      $ps1FullPath = $ps1.FullName
      & "$ps1FullPath"
      $env:chocolateyInstallArguments = ''
      $env:chocolateyInstallOverride = $null
      
      # $importChocolateyHelpers = "";
      # Get-ChildItem "$nugetChocolateyPath\helpers" -Filter *.psm1 | ForEach-Object { $importChocolateyHelpers = "& import-module -name  `'$($_.FullName)`';$importChocolateyHelpers" };
      # Run-ChocolateyProcess powershell "-NoProfile -ExecutionPolicy unrestricted -Command `"$importChocolateyHelpers & `'$ps1FullPath`'`"" -elevated
      ##testing Start-Process -FilePath "powershell.exe" -ArgumentList " -noexit `"$ps1FullPath`"" -Verb "runas"  -Wait  #-PassThru -UseNewEnvironment ##-RedirectStandardError $errorLog -WindowStyle Normal
      
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

function Chocolatey-Update {
param([string] $packageName ='', $source = 'https://go.microsoft.com/fwlink/?LinkID=230477')

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  
  $packages = $packageName
  if ($packageName -eq 'all') {
		$packageFolders = Get-ChildItem $nugetLibPath | sort name
		$packages = $packageFolders -replace "(\.\d{1,})+"|gu 
	}

	foreach ($package in $packages) {
		$versions = Chocolatey-Version $package $source
		if ($versions -ne $null -and $versions.'foundCompare' -lt $versions.'latestCompare') {
			Chocolatey-NuGet $package $source
		}
	}
}

function Chocolatey-List {
  param([string]$selector='', [string]$source='https://go.microsoft.com/fwlink/?LinkID=230477' );
  
  if ($source -like 'webpi') {
    $webpiArgs ="/c webpicmd /List /ListOption:All"
    & cmd.exe $webpiArgs 
  } else {  
  
    $srcArgs = "-Source `"$source`""
    if ($source -like 'https://go.microsoft.com/fwlink/?LinkID=230477') {
      $srcArgs = "-Source `"http://chocolatey.org/api/v2/`" -Source `"$source`""
    }
    
    $parameters = "list"
    if ($selector -ne '') {
      $parameters = "$parameters ""$selector"""
    }
    
    if ($allVersions -eq $true) {
      $parameters = "$parameters -all"
    }
    
    if ($prerelease -eq $true) {
      $parameters = "$parameters -Prerelease";
    }
    
    $parameters = "$parameters $srcArgs"
    #write-host "TEMP: Args - $parameters"

    Start-Process $nugetExe -ArgumentList $parameters -NoNewWindow -Wait 
  }
} 

function Chocolatey-Version {
param(
  [string]$packageName='',
  [string]$source='https://go.microsoft.com/fwlink/?LinkID=230477'
)

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  
  $packages = $packageName
  if ($packageName -eq 'all') {
    $packageFolders = Get-ChildItem $nugetLibPath | sort name
    $packages = $packageFolders -replace "(\.\d{1,})+"|gu 
  }
  
  $srcArgs = "-Source `"$source`""
  if ($source -like 'https://go.microsoft.com/fwlink/?LinkID=230477') {
    $srcArgs = "-Source `"http://chocolatey.org/api/v2/`" -Source `"$source`""
  }
  
  foreach ($package in $packages) {
    $packageArgs = "list ""$package"" $srcArgs"
    if ($prerelease -eq $true) {
      $packageArgs = $packageArgs + " -Prerelease";
    }
    #write-host "TEMP: Args - $packageArgs"

    $logFile = Join-Path $nugetChocolateyPath 'list.log'
    Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile
    Start-Sleep 1 #let it finish writing to the config file

    $versionLatest = Get-Content $logFile | ?{$_ -match "^$package\s+\d+"} | sort $_ -Descending | select -First 1 
    $versionLatest = $versionLatest -replace "$package ", "";
    #todo - make this compare prerelease information as well
    $versionLatestCompare = Get-LongPackageVersion $versionLatest

    $versionFound = $chocVer
    if ($packageName -ne 'chocolatey') {
      $versionFound = 'no version'
      $packageFolderVersion = Get-LatestPackageVersion(Get-PackageFolderVersions($package))

      if ($packageFolderVersion -notlike '') { 
        #Write-Host $packageFolder
        $versionFound = $packageFolderVersion
      }
    }
    
    $versionFoundCompare = ''
    if ($versionFound -ne 'no version') {
      #todo - make this compare prerelease information as well
      $versionFoundCompare = Get-LongPackageVersion $versionFound
    }    
  
    $verMessage = "The most recent version of $package available from ($source) is $versionLatest. On your machine you have $versionFound installed."
    if ($versionLatest -eq $versionFound) { 
      $verMessage = "You have the latest version of $package ($versionLatest) based on ($source)."
    }
    if ($versionLatestCompare -lt $versionFoundCompare) {
      $verMessage = "$verMessage You must be smarter than the average bear..."
    }
    if ($versionLatest -eq '') {
      $verMessage = "$package does not appear to be on ($source). You have $versionFound installed. Interesting..."
    }
    Write-Host $verMessage
  }
  
	$versions = @{latest = $versionLatest; found = $versionFound; latestCompare = $versionLatestCompare; foundCompare = $versionFoundCompare; }
	return $versions
}

function Chocolatey-InstallIfMissing {
param([string] $packageName, $source = 'https://go.microsoft.com/fwlink/?LinkID=230477',$version = '')
  
  $versions = Chocolatey-Version $packageName $source
  
  if ($versions.'found' -contains 'no version' -or ($version -ne '' -and $versions.'found' -ne $version)) {
    Chocolatey-NuGet $packageName $source $version
  }
}

function Chocolatey-WebPI {
param([string] $packageName, [string] $installerArguments ='')
  Chocolatey-InstallIfMissing 'webpicommandline'
  
@"
$h1
Chocolatey ($chocVer) is installing `'$packageName`' (using WebPI)
$h1
Package License Acceptance Terms
$h2
Please run chocolatey /? for full license acceptance verbage. By installing you accept the license for the package you are installing...
$h2
"@ | Write-Host
  
  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWebPiInstall.log';
  Remove-LastInstallLog $chocoInstallLog
 
  $webpiArgs = "/c webpicmd /Install /AcceptEula /SuppressReboot /Products:$packageName"
  if ($installerArguments -ne '') {
    $webpiArgs = "$webpiArgs $installerArguments"
  }
  if ($overrideArgs -eq $true) {
    $webpiArgs = "/c webpicmd $installerArguments /Products:$packageName"
    write-host "Overriding arguments for WebPI"
  }  
  
  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $webpiArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..."
  
  #Start-Process -FilePath "cmd" -ArgumentList "$webpiArgs" -Verb "runas"  -Wait >$chocoInstallLog #-PassThru -UseNewEnvironment >
  #Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $webpiArgs | Out-String`"" -Verb "runas"  -Wait | Write-Host  #-PassThru -UseNewEnvironment
  Start-Process -FilePath "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy unrestricted -Command `"cmd.exe $webpiArgs | Tee-Object -FilePath $chocoInstallLog`"" -Verb "RunAs"  -Wait -WindowStyle Minimized
  
  $webpiOutput = Get-Content $chocoInstallLog -Encoding Ascii
	foreach ($line in $webpiOutput) {
    Write-Host $line
  }
  
@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}

function Chocolatey-RubyGem {
param([string] $packageName, $version ='', [string] $installerArguments ='')
  Chocolatey-InstallIfMissing 'ruby'
  
@"
$h1
Chocolatey ($chocVer) is installing Ruby Gem `'$packageName`' (using RubyGems.org)
$h1
Package License Acceptance Terms
$h2
Please run chocolatey /? for full license acceptance verbage. By installing you accept the license for the package you are installing...
$h2
"@ | Write-Host
  
  if ($($env:Path).ToLower().Contains("ruby") -eq $false) {
    $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
  }
  
  $packageArgs = "/c gem install $packageName"
  if ($version -notlike '') {
    $packageArgs = $packageArgs + " -v $version";
  }
  & cmd.exe $packageArgs
  
  if ($installerArguments -ne '') {
    $packageArgs = $packageArgs + " -v $version $installerArguments";
  }

@"
$h1
Chocolatey has finished installing `'$packageName`' - check log for errors.
$h1
"@ | Write-Host
}

function Remove-LastInstallLog{
param([string] $chocoInstallLog = '')
  if ($chocoInstallLog -eq '') {
    $chocoInstallLog = (Join-Path $nugetChocolateyPath 'chocolateyInstall.log')
  }
	try {
    if ([System.IO.File]::Exists($chocoInstallLog)) {[System.IO.File]::Delete($chocoInstallLog)}
  } catch {
    Write-Error "Could not delete `'$chocoInstallLog`': $($_.Exception.Message)"
  }
}

function Chocolatey-Pack {
param([string] $packageName)

  $packageArgs = "pack $packageName -NoPackageAnalysis"
  $logFile = Join-Path $nugetChocolateyPath 'pack.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  
  Write-Host "Calling `'$nugetExe $packageArgs`'."
  
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
}

function Chocolatey-Push {
param([string] $packageName, $source = 'http://chocolatey.org/' )

  $srcArgs = "-source $source"
  if ($source -like 'https://go.microsoft.com/fwlink/?LinkID=230477') {
    $srcArgs = "-source http://chocolatey.org/"
  }

  $packageArgs = "push $packageName $srcArgs"
  $logFile = Join-Path $nugetChocolateyPath 'push.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  
  Write-Host "Calling `'$nugetExe $packageArgs`'. This may take a few minutes. Please wait for the command to finish."
  
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
}


#main entry point
Remove-LastInstallLog

switch -wildcard ($command) 
{
  "install" { Chocolatey-Install $packageName $source $version $installArguments; }
  "installmissing" { Chocolatey-InstallIfMissing $packageName $source $version; }
  "update" { Chocolatey-Update $packageName $source; }
  "list" { Chocolatey-List $packageName $source; }
  "version" { Chocolatey-Version $packageName $source; }
  "webpi" { Chocolatey-WebPI $packageName $installArguments; }
  "gem" { Chocolatey-RubyGem $packageName $version $installArguments; }
  "pack" { Chocolatey-Pack $packageName; }
  "push" { Chocolatey-Push $packageName $source; }
  default { Chocolatey-Help; }
}
