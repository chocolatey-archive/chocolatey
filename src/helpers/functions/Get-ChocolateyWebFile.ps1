function Get-ChocolateyWebFile {
<#
.SYNOPSIS
Downloads a file from the internets.

.DESCRIPTION
This will download a file from a url, tracking with a progress bar. 
It returns the filepath to the downloaded file when it is complete.

.PARAMETER PackageName
The name of the package we want to download - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER FileFullPath
This is the full path of the resulting file name.

.PARAMETER Url
This is the url to download the file from. 

.PARAMETER Url64bit
OPTIONAL - If there is an x64 installer to download, please include it here. If not, delete this parameter

.EXAMPLE
Get-ChocolateyWebFile '__NAME__' 'C:\somepath\somename.exe' 'URL' '64BIT_URL_DELETE_IF_NO_64BIT'

.NOTES
This helper reduces the number of lines one would have to write to download a file to 1 line.
There is no error handling built into this method.

.LINK
Install-ChocolateyPackage
#>
param(
  [string] $packageName,
  [string] $fileFullPath,
  [string] $url,
  [string] $url64bit = $url
)
  Write-Debug "Running 'Get-ChocolateyWebFile' for $packageName with url:`'$url`', fileFullPath:`'$fileFullPath`',and url64bit:`'$url64bit`'";
  
  $url32bit = $url;
  $processor = Get-WmiObject Win32_Processor
  $procCount=(Get-WmiObject Win32_ComputerSystem).NumberofProcessors
  if ($procCount -eq '1') {
     $is64bit = $processor.AddressWidth -eq 64
     Write-Debug "Processor width is $($processor.AddressWidth)."
	 } else {
	 Write-Debug "First processor width is $($processor[0].AddressWidth)."
	 $is64bit = $processor[0].AddressWidth -eq 64
	 }
  $systemBit = '32 bit'
  if ($is64bit) {
    $systemBit = '64 bit';
    $url = $url64bit;
  }
  
  $downloadMessage = "Downloading $packageName ($url) to $fileFullPath"
  if ($url32bit -ne $url64bit) {$downloadMessage = "Downloading $packageName $systemBit ($url) to $fileFullPath.";}
  Write-Host "$downloadMessage"
  #$downloader = new-object System.Net.WebClient
  #$downloader.DownloadFile($url, $fileFullPath)
  if ($url.StartsWith('http')) {
    Get-WebFile $url $fileFullPath
  } elseif ($url.StartsWith('ftp')) {
    Get-FtpFile $url $fileFullPath
  } else {
    Write-Debug "We are attempting to copy the local item `'$url`' to `'$fileFullPath`'"
    Copy-Item $url -Destination $fileFullPath -Force
  }
  
  Start-Sleep 2 #give it a sec or two to finish up
}