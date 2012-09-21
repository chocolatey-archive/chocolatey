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
There is no error handling built into this method.

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
  
  Write-Debug "Running 'Get-ChocolateyUnzip' with fileFullPath:`'$fileFullPath`'',destination:$destination";

  Write-Host "Extracting $fileFullPath to $destination..."
  if (![System.IO.Directory]::Exists($destination)) {[System.IO.Directory]::CreateDirectory($destination)}
  
  $shellApplication = new-object -com shell.application 
  $zipPackage = $shellApplication.NameSpace($fileFullPath) 
  $destinationFolder = $shellApplication.NameSpace($destination)
  $zipPackageItems = $zipPackage.Items()
  $destinationFolder.CopyHere($zipPackageItems,0x10) 

  if ($packageName) {
    $packagelibPath=$env:chocolateyPackageFolder
    if (!(Test-Path -path $packagelibPath)) {
      New-Item $packagelibPath -type directory
    }
 
  $zipFilename=split-path $zipfileFullPath -Leaf
  $zipExtractLogFullPath=join-path $packagelibPath $zipFilename`.txt
  Get-ZipItems_Recursive $zipPackageItems $specificFolder $destination |add-content $zipExtractLogFullPath
  }
  return $destination
}

function Get-ZipItems_recursive {
  param(
    [object]$subitems,
    [string]$specificFolder,
    [string]$target)
    
  foreach($file in $subitems) {
    if($file.getfolder -ne $null) {
      Get-ZipItems_recursive $file.getfolder.items() $specificfolder $target
    }
    $extension=".zip"
    $pathStrip=join-path $extension $specificFolder
    $fileIndex=$file.path.indexof("$pathStrip")+$pathStrip.Length
    $insideZipFile=$file.path.substring($fileIndex)
    $finalFilePath=join-path $target $insideZipFile
    write-output $finalFilePath
    
  }
} 