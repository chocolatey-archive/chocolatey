param(
  [parameter(Position=0)]
  [string]$command,
  [string]$source='',
  [string]$version='',
  [alias("all")][switch] $allVersions = $false,
  [alias("ia","installArgs")][string] $installArguments = '',
  [alias("o","override","overrideArguments","notSilent")]
  [switch] $overrideArgs = $false,
  [alias("f")][switch] $force = $false,
  [alias("pre")][switch] $prerelease = $false,
  [alias("lo")][switch] $localonly = $false,
  [alias("v")][switch] $verbosity = $false,
  #[switch] $debug,
  [string] $name,
  [switch] $ignoreDependencies = $false,
  [alias("x86")][switch] $forceX86 = $false,
  [alias("params")][alias("parameters")][alias("pkgParams")][string]$packageParameters = '',
  [alias("q")][switch] $quiet = $false,
  [parameter(Position=1, ValueFromRemainingArguments=$true)]
  [string[]]$packageNames=@('')
)

[switch] $debug = $false
if ($PSBoundParameters['Debug']) {
 $debug = $true
}

if ($PSBoundParameters['Verbose']) {
  $verbosity = $true
}

# chocolatey
# Copyright (c) 2011-Present Rob Reynolds & RealDimensions Software, LLC
# Committers and Contributors: Rob Reynolds, Rich Siegel, Matt Wrock, Anthony Mastrean, Alan Stevens, Gary Ewan Park
# Crediting contributions by Chris Ortman, Nekresh, Staxmanade, Chrissie1, AnthonyMastrean, Rich Siegel, Matt Wrock and other contributors from the community.
# Big thanks to Keith Dahlby for all the powershell help!
# Apache License, Version 2.0 - http://www.apache.org/licenses/LICENSE-2.0

## Set the culture to invariant
$currentThread = [System.Threading.Thread]::CurrentThread;
$culture = [System.Globalization.CultureInfo]::InvariantCulture;
$currentThread.CurrentCulture = $culture;
$currentThread.CurrentUICulture = $culture;

#Let's get Chocolatey!
$chocVer = '0.9.8.31'
$nugetChocolateyPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
$nugetPath = (Split-Path -Parent $nugetChocolateyPath)
$nugetExePath = Join-Path $nuGetPath 'bin'
$nugetLibPath = Join-Path $nuGetPath 'lib'
$badLibPath = Join-Path $nuGetPath 'lib-bad'
$extensionsPath = Join-Path $nugetPath 'extensions'
$chocInstallVariableName = "ChocolateyInstall"
$nugetExe = Join-Path $nugetChocolateyPath 'nuget.exe'
$7zip = Join-Path $nugetChocolateyPath 'tools\7za.exe'
$ShimGen = Join-Path $nugetChocolateyPath 'tools\shimgen.exe'
$checksumExe = Join-Path $nugetChocolateyPath 'tools\checksum.exe'
$h1 = '====================================================='
$h2 = '-------------------------'
$globalConfig = ''
$userConfig = ''
$env:ChocolateyEnvironmentDebug = 'false'
$env:ChocolateyEnvironmentQuiet = 'false'
$RunNote = "DarkCyan"
$Warning = "Magenta"
$ErrorColor = "Red"
$Note = "Green"


$DebugPreference = "SilentlyContinue"
if ($debug) {
  $DebugPreference = "Continue";
  $env:ChocolateyEnvironmentDebug = 'true'
}
# ensure module loading preference is on
$PSModuleAutoLoadingPreference = "All";

if ($quiet) {
  $env:ChocolateyEnvironmentQuiet = 'true'
}

# check permission of process and issue warning - we can't use
# Test-ProcessAdminRights b/c it would use overridden Write-Debug/Write-Host
# which may log into a folder the user doesn't have access to write to.
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent([Security.Principal.TokenAccessLevels]'Query,Duplicate'))
if (!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
@"
Chocolatey detected you are not running from an elevated command shell
  (cmd/powershell). You may experience errors - many functions/packages
  require admin rights. Only advanced users should run choco w/out an
  elevated shell (and very advanced users as non-admin). When you open
  the command shell, you should ensure "Run as Administrator".
"@ | Write-Host  -ForegroundColor $Warning -BackgroundColor Black
}

$installModule = Join-Path $nugetChocolateyPath (Join-Path 'helpers' 'chocolateyInstaller.psm1')
Import-Module $installModule

# grab functions from files
Resolve-Path $nugetChocolateyPath\functions\*.ps1 |
    ? { -not ($_.ProviderPath.Contains(".Tests.")) } |
    % { . $_.ProviderPath }

# load extensions if they exist
if(Test-Path($extensionsPath)) {
  Write-Debug 'Loading community extensions'
  #Resolve-Path $extensionsPath\**\*\*.psm1 | % { Write-Debug "Importing `'$_`'"; Import-Module $_.ProviderPath }
  Get-ChildItem $extensionsPath -recurse -filter "*.psm1" | Select -ExpandProperty FullName | % { Write-Debug "Importing `'$_`'"; Import-Module $_; }
}

# issue deprecation Warning
if ($nugetPath -eq (Join-Path $env:SystemDrive 'chocolatey')) {
  $programData = [Environment]::GetFolderPath("CommonApplicationData")
  $newChocoPath = Join-Path "$programData" 'chocolatey'
@"
The default install location has been changed to '$newChocoPath'.
  This install will be updated to that location in the next version. It
  is strongly suggested you move this installation to the new location
  as soon as possible to limit write access from all users. Do not forget
  to update PATH & $chocInstallVariableName environment variables.
"@ | Write-Host  -ForegroundColor $Warning -BackgroundColor Black
}

$cacheLocation = Get-ConfigValue 'cacheLocation'
if ($cacheLocation -ne '' -or $env:Temp -eq $null) {
  if ($cacheLocation -eq '') { $cacheLocation = "$nugetPath\temp"}

  if ($env:Temp -eq $null) {
    Write-Warning "`$env:Temp was not set, setting to '$cacheLocation'"
  } else {
    Write-Debug "Switching `$env:Temp to '$cacheLocation'"
  }
  $env:Temp = $cacheLocation

  if (![System.IO.Directory]::Exists($cacheLocation)) {
    [System.IO.Directory]::CreateDirectory($cacheLocation) | out-null
  }
}

# bump installarguments back to quotes
$installArguments = $installArguments.Replace("'","""")
$packageParameters = $packageParameters.Replace("'","""")

#main entry point
Append-Log

Write-Debug "Arguments: `$command = '$command'|`$force=$force`
|`$prerelease=$prerelease|`$packageNames='$packageNames'`
|`$source='$source'`
|`$version='$version'|`$allVersions=$allVersions`
|`$overrideArguments=$overrideArgs|`$InstallArguments='$installArguments'`
|`$localonly=$localonly|`$verbosity=$verbosity|`$debug=$debug|`$quiet=$quiet`
|`$name='$name'|`$ignoreDependencies=$ignoreDependencies|`$forceX86=$forceX86`
|`$packageParameters='$packageParameters'`
|PowerShellVersion=$($host.version)|OSVersion=$([System.Environment]::OSVersion.Version.ToString())"

$currentProtocol = [System.Net.ServicePointManager]::SecurityProtocol
Write-Debug "Current Security Protocol - $currentProtocol"

# run level environment variables
$env:chocolateyForceX86 = $null
if ($forceX86) {
  $env:chocolateyForceX86 = $true
}

$env:chocolateyPackageParameters = $packageParameters

$script:chocolateyErrored = $false
$badPackages = ''

#todo: This does not catch package names that come later
foreach ($packageName in $packageNames) {
  try {
    switch -wildcard ($command) {
      "install"         { Chocolatey-Install $packageName $source $version $installArguments }
      "installmissing"  { Chocolatey-InstallIfMissing $packageName $source $version }
      "update"          { Chocolatey-Update $packageName $source }
      "uninstall"       { Chocolatey-Uninstall $packageName $version $installArguments }
      "search"          { Chocolatey-List $packageName $source }
      "list"            { Chocolatey-List $packageName $source }
      "version"         { Chocolatey-Version $packageName $source }
      "webpi"           { Chocolatey-WebPI $packageName $installArguments }
      "windowsfeatures" { Chocolatey-WindowsFeatures $packageName }
      "cygwin"          { Chocolatey-Cygwin $packageName $installArguments }
      "python"          { Chocolatey-Python $packageName $version $installArguments }
      "gem"             { Chocolatey-RubyGem $packageName $version $installArguments }
      "pack"            { Chocolatey-Pack $packageName }
      "push"            { Chocolatey-Push $packageName $source }
      "help"            { Chocolatey-Help}
      "sources"         { Chocolatey-Sources $packageName $name $source }
      default           {Write-Host "Please run chocolatey /? or chocolatey help - chocolatey v$chocVer";}
    }
  }
  catch {
    $script:chocolateyErrored = $true
    Write-Host "$($_.Exception.Message)" -BackgroundColor $ErrorColor -ForegroundColor White ;
    if ($badPackages -ne '') { $badPackages += ', '}
    $badPackages += "$packageName"
  }
  finally {
    # ensure protocol is reset appropriately
    [System.Net.ServicePointManager]::SecurityProtocol = $currentProtocol
  }
}

if ($badPackages -ne '') {
 Write-Host "Command `'$command`' failed (sometimes this indicates a partial failure). Additional info/packages: $badpackages" -BackgroundColor $ErrorColor -ForegroundColor White
}

if ($script:chocolateyErrored) {
  Write-Debug "Exiting with non-zero exit code."
  exit 1
}

exit 0
