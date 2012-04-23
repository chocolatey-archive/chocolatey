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

.EXAMPLE
$scriptPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
Get-ChocolateyUnzip "c:\someFile.zip" $scriptPath

.OUTPUTS
Returns the passed in $destination.

.NOTES
This helper reduces the number of lines one would have to write to unzip a file to 1 line.
There is no error handling built into this method.

#>
param(
  [string] $fileFullPath, 
  [string] $destination
)

	Write-Host "Extracting $fileFullPath to $destination..."
  if (![System.IO.Directory]::Exists($destination)) {[System.IO.Directory]::CreateDirectory($destination)}
  
	$shellApplication = new-object -com shell.application 
	$zipPackage = $shellApplication.NameSpace($fileFullPath) 
	$destinationFolder = $shellApplication.NameSpace($destination) 
	$destinationFolder.CopyHere($zipPackage.Items(),0x10) 
  
  return $destination
}