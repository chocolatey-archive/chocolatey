function Get-ChocolateyUnzip {
<#
.SYNOPSIS
Unzips a .zip file and returns the location for further processing.

.DESCRIPTION
This unzips files using the native windows unzipper.

.PARAMETER FileFullPath
This is the full path to your zip file.

.PARAMETER Destination
This is a directory where you would like the unzipped files to end up.

.PARAMETER SpecificFolder
OPTIONAL - This is a specific directory within zip file to extract.

.PARAMETER PackageName
OPTIONAL - This will faciliate logging unzip activity for subsequent uninstall

.EXAMPLE
$scriptPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
Get-ChocolateyUnzip "c:\someFile.zip" $scriptPath somedirinzip\somedirinzip

.OUTPUTS
Returns the passed in $destination.

.NOTES
This helper reduces the number of lines one would have to write to unzip a file to 1 line.
If extraction fails, an exception is thrown.

#>
param(
  [string] $fileFullPath,
  [string] $destination,
  [string] $specificFolder,
  [string] $packageName
)
  $zipfileFullPath=$fileFullPath
  if ($specificfolder) {
    $fileFullPath=join-path $fileFullPath $specificFolder
  }

  Write-Debug "Running 'Get-ChocolateyUnzip' with fileFullPath:`'$fileFullPath`'', destination: `'$destination`', specificFolder: `'$specificFolder``, packageName: `'$packageName`'";

  if ($packageName) {
    $packagelibPath=$env:chocolateyPackageFolder
    if (!(Test-Path -path $packagelibPath)) {
      New-Item $packagelibPath -type directory
    }

    $zipFilename=split-path $zipfileFullPath -Leaf
    $zipExtractLogFullPath=join-path $packagelibPath $zipFilename`.txt
  }

  Write-Host "Extracting $fileFullPath to $destination..."
  if (![System.IO.Directory]::Exists($destination)) {[System.IO.Directory]::CreateDirectory($destination)}

  # On first install, env:ChocolateyInstall might be null still - join-path has issues
  $7zip = Join-Path "$env:SystemDrive" 'chocolatey\chocolateyinstall\tools\7za.exe'
  if ($env:ChocolateyInstall){
    $7zip = Join-Path "$env:ChocolateyInstall" 'chocolateyinstall\tools\7za.exe'
  }

  $exitCode = -1
  $unzipOps = {
    param($7zip, $destination, $fileFullPath, [ref]$exitCodeRef)
    $p = Start-Process $7zip -ArgumentList "x -o`"$destination`" -y `"$fileFullPath`"" -Wait -WindowStyle Hidden -PassThru
    $exitCodeRef.Value = $p.ExitCode
  }

  if ($zipExtractLogFullPath) {
    Write-Debug "wrapping 7za invocation with Write-FileUpdateLog"
    Write-FileUpdateLog -logFilePath $zipExtractLogFullPath -locationToMonitor $destination -scriptToRun $unzipOps -argumentList $7zip,$destination,$fileFullPath,([ref]$exitCode)
  } else {
    Write-Debug "calling 7za directly"
    Invoke-Command $unzipOps -ArgumentList $7zip,$destination,$fileFullPath,([ref]$exitCode)
  }

  Write-Debug "7za exit code: $exitCode"
  switch ($exitCode) {
    0 { break }
    1 { throw 'Some files could not be extracted' } # this one is returned e.g. for access denied errors
    2 { throw '7-Zip encountered a fatal error while extracting the files' }
    7 { throw '7-Zip command line error' }
    8 { throw '7-Zip out of memory' }
    255 { throw 'Extraction cancelled by the user' }
    default { throw "7-Zip signalled an unknown error (code $exitCode)" }
  }

  return $destination
}
