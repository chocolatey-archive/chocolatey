function Install-ChocolateyPackage {
<#
.SYNOPSIS
Installs a package

.DESCRIPTION
This will download a file from a url and install it on your machine.

.PARAMETER PackageName
The name of the package we want to download - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER FileType
This is the extension of the file. This should be either exe or msi.

.PARAMETER SilentArgs
OPTIONAL - These are the parameters to pass to the native installer.
Try any of these to get the silent installer - /s /S /q /Q /quiet /silent /SILENT /VERYSILENT
With msi it is always /quiet. Please pass it in still but it will be overridden by chocolatey to /quiet.
If you don't pass anything it will invoke the installer with out any arguments. That means a nonsilent installer.

Please include the notSilent tag in your chocolatey nuget package if you are not setting up a silent package.

.PARAMETER Url
This is the url to download the file from. 

.PARAMETER Url64bit
OPTIONAL - If there is an x64 installer to download, please include it here. If not, delete this parameter

.EXAMPLE
Install-ChocolateyPackage '__NAME__' 'EXE_OR_MSI' 'SILENT_ARGS' 'URL' '64BIT_URL_DELETE_IF_NO_64BIT'

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to download and install a file to 1 line.
This method has error handling built into it.

.LINK
Get-ChocolateyWebFile
Install-ChocolateyInstallPackage
#>
param([string] $packageName, [string] $fileType = 'exe',[string] $silentArgs = '',[string] $url,[string] $url64bit = $url)
	try {
    $chocTempDir = Join-Path $env:TEMP "chocolatey"
    $tempDir = Join-Path $chocTempDir "$packageName"
    if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
    $file = Join-Path $tempDir "$($packageName)Install.$fileType"
  
    Get-ChocolateyWebFile $packageName $file $url $url64bit
    Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $file
		Write-ChocolateySuccess $packageName
		Start-Sleep 8
	} catch {
@"
Error Occurred: $($_.Exception.Message)
"@ | Write-Host -ForegroundColor White -BackgroundColor DarkRed
		Write-ChocolateyFailure $packageName $($_.Exception.Message)
		Start-Sleep 7
		throw 
	}
}

function Install-ChocolateyZipPackage {
<#
.SYNOPSIS
Downloads and unzips a package

.DESCRIPTION
This will download a file from a url and unzip it on your machine.

.PARAMETER PackageName
The name of the package we want to download - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER Url
This is the url to download the file from. 

.PARAMETER UnzipLocation
This is a location to unzip the contents to, most likely your script folder.

.EXAMPLE
Install-ChocolateyZipPackage '__NAME__' 'URL' "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to download and unzip a file to 1 line.
This method has error handling built into it.

.LINK
  Get-ChocolateyWebFile
  Get-ChocolateyUnzip
#>
param([string] $packageName, [string] $url,[string] $unzipLocation)

	try {
	  $fileType = 'zip'
	  
	  $chocTempDir = Join-Path $env:TEMP "chocolatey"
		$tempDir = Join-Path $chocTempDir "$packageName"
		if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
		$file = Join-Path $tempDir "$($packageName)Install.$fileType"
	  
	  Get-ChocolateyWebFile $packageName $file $url  
	  Get-ChocolateyUnzip "$file" $unzipLocation
	  Write-ChocolateySuccess $packageName
				
		write-host "$packageName has been unzipped."
		Start-Sleep 5
	} catch {
@"
Error Occurred: $($_.Exception.Message)
"@ | Write-Host -ForegroundColor White -BackgroundColor DarkRed
		Write-ChocolateyFailure $packageName $($_.Exception.Message)
		Start-Sleep 7
		throw 
	}
}

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
param([string] $packageName,[string] $fileFullPath,[string] $url,[string] $url64bit = $url)
  
	$url32bit = $url;
	$processor = Get-WmiObject Win32_Processor
	$is64bit = $processor.AddressWidth -eq 64
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
  Get-WebFile $url $fileFullPath
	
  Start-Sleep 2 #give it a sec
}

function Install-ChocolateyInstallPackage {
<#
.SYNOPSIS
Installs a package

.DESCRIPTION
This will run an installer (local file) on your machine.

.PARAMETER PackageName
The name of the package - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER FileType
This is the extension of the file. This should be either exe or msi.

.PARAMETER SilentArgs
OPTIONAL - These are the parameters to pass to the native installer.
Try any of these to get the silent installer - /s /S /q /Q /quiet /silent /SILENT /VERYSILENT
With msi it is always /quiet.
If you don't pass anything it will invoke the installer with out any arguments. That means a nonsilent installer.

Please include the notSilent tag in your chocolatey nuget package if you are not setting up a silent package.

.PARAMETER File
The full path to the native installer to run

.EXAMPLE
Install-ChocolateyInstallPackage '__NAME__' 'EXE_OR_MSI' 'SILENT_ARGS' 'FilePath'

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to run an installer to 1 line.
There is no error handling built into this method.

.LINK
Install-ChocolateyPackage
#>
param([string] $packageName, [string] $fileType = 'exe',[string] $silentArgs = '',[string] $file)
$installMessage = "Installing $packageName..."
	if ($silentArgs -ne '') { $installMessage = "$installMessage silently...";}
	write-host $installMessage
	
	if ($fileType -like 'msi') {
		$msiArgs = "/i `"$file`"" 
		if ($silentArgs -ne '') { $msiArgs = "$msiArgs $silentArgs";}
		Start-Process -FilePath msiexec -ArgumentList $msiArgs -Wait
	}
	if ($fileType -like 'exe') {
		if ($silentArgs -ne '') {
			Start-Process -FilePath $file -ArgumentList $silentArgs -Wait 
		} else {
			Start-Process -FilePath $file -Wait 
		}
	}
	
	write-host "$packageName has been installed."
	Start-Sleep 3
}

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
param([string] $fileFullPath, [string] $destination)

	Write-Host "Extracting $fileFullPath to $destination..."
	$shellApplication = new-object -com shell.application 
	$zipPackage = $shellApplication.NameSpace($fileFullPath) 
	$destinationFolder = $shellApplication.NameSpace($destination) 
	$destinationFolder.CopyHere($zipPackage.Items()) 
  
  return $destination
}

function Write-ChocolateySuccess {
param([string] $packageName)
	$logFile = Join-Path (Get-Location) 'success.log'
	#Write-Host "Writing to $logFile"
@"
$packageName has finished succesfully! The chocolatey gods have answered your request!
"@ #| Out-File $logFile
}

function Write-ChocolateyFailure {
param([string] $packageName,[string] $failureMessage)
	$logFile = Join-Path (Get-Location) 'failure.log'
	#Write-Host "Writing to $logFile"
@" 
$packageName did not finish successfully. Boo to the chocolatey gods!
-----------------------
$failureMessage
-----------------------
"@ #| Out-File $logFile
}

Export-ModuleMember -Function Install-ChocolateyPackage, Install-ChocolateyZipPackage, Get-ChocolateyWebFile, Install-ChocolateyInstallPackage, Get-ChocolateyUnzip, Write-ChocolateySuccess, Write-ChocolateyFailure

# http://poshcode.org/417
## Get-WebFile (aka wget for PowerShell)
##############################################################################################################
## Downloads a file or page from the web
## History:
## v3.6 - Add -Passthru switch to output TEXT files
## v3.5 - Add -Quiet switch to turn off the progress reports ...
## v3.4 - Add progress report for files which don't report size
## v3.3 - Add progress report for files which report their size
## v3.2 - Use the pure Stream object because StreamWriter is based on TextWriter:
##        it was messing up binary files, and making mistakes with extended characters in text
## v3.1 - Unwrap the filename when it has quotes around it
## v3   - rewritten completely using HttpWebRequest + HttpWebResponse to figure out the file name, if possible
## v2   - adds a ton of parsing to make the output pretty
##        added measuring the scripts involved in the command, (uses Tokenizer)
##############################################################################################################
function Get-WebFile {
   param(
      $url = (Read-Host "The URL to download"),
      $fileName = $null,
      [switch]$Passthru,
      [switch]$quiet
   )
   
   $req = [System.Net.HttpWebRequest]::Create($url);
   $res = $req.GetResponse();
 
   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   }
   elseif((!$Passthru -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)))
   {
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/""'")
      if(!$fileName) {
         $fileName = $res.ResponseUri.Segments[-1]
         $fileName = $fileName.trim("\/")
         if(!$fileName) {
            $fileName = Read-Host "Please provide a file name"
         }
         $fileName = $fileName.trim("\/")
         if(!([IO.FileInfo]$fileName).Extension) {
            $fileName = $fileName + "." + $res.ContentType.Split(";")[0].Split("/")[1]
         }
      }
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   }
   if($Passthru) {
      $encoding = [System.Text.Encoding]::GetEncoding( $res.CharacterSet )
      [string]$output = ""
   }
 
   if($res.StatusCode -eq 200) {
      [int]$goal = $res.ContentLength
      $reader = $res.GetResponseStream()
      if($fileName) {
         $writer = new-object System.IO.FileStream $fileName, "Create"
      }
      [byte[]]$buffer = new-object byte[] 4096
      [int]$total = [int]$count = 0
      do
      {
         $count = $reader.Read($buffer, 0, $buffer.Length);
         if($fileName) {
            $writer.Write($buffer, 0, $count);
         }
         if($Passthru){
            $output += $encoding.GetString($buffer,0,$count)
         } elseif(!$quiet) {
            $total += $count
            if($goal -gt 0) {
               Write-Progress "Downloading $url to $fileName" "Saving $total of $goal" -id 0 -percentComplete (($total/$goal)*100) 
						} else {
               Write-Progress "Downloading $url to $fileName" "Saving $total bytes..." -id 0 -Completed
            }
						if ($total -eq $goal) {
							Write-Progress "Completed download of $url." "Completed a total of $total bytes of $fileName" -id 0 -Completed 
						}
         }
      } while ($count -gt 0)
     
      $reader.Close()
      if($fileName) {
         $writer.Flush()
         $writer.Close()
      }
      if($Passthru){
         $output
      }
   }
   $res.Close();
}
