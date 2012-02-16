$helpersPath = (Split-Path -parent $MyInvocation.MyCommand.Definition);

function Start-ChocolateyProcessAsAdmin {
param(
  [string] $statements, 
  [string] $exeToRun = 'powershell',
  [string] $validExitCodes = @(0)
)

  $wrappedStatements = $statements;
  if ($exeToRun -eq 'powershell') {
    $exeToRun = "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe"
    if (!$statements.EndsWith(';')){$statements = $statements + ';'}
    $importChocolateyHelpers = "";
    Get-ChildItem "$helpersPath" -Filter *.psm1 | ForEach-Object { $importChocolateyHelpers = "& import-module -name  `'$($_.FullName)`';$importChocolateyHelpers" };
    $wrappedStatements = "-NoProfile -ExecutionPolicy unrestricted -Command `"$importChocolateyHelpers try{$statements start-sleep 6;}catch{write-error `'That was not sucessful`';start-sleep 8;throw;}`""
  }
@"
Elevating Permissions and running $exeToRun $wrappedStatements. This may take awhile, depending on the statements.
"@ | Write-Host

  $psi = new-object System.Diagnostics.ProcessStartInfo;
  $psi.FileName = $exeToRun;
  if ($wrappedStatements -ne '') {
    $psi.Arguments = "$wrappedStatements";
  }
  $psi.Verb = "runas";
  $psi.WorkingDirectory = get-location;
 
  $s = [System.Diagnostics.Process]::Start($psi);
  $s.WaitForExit();
  if ($validExitCodes -notcontains $s.ExitCode) {
    $errorMessage = "[ERROR] Running $exeToRun with $statements was not successful."
    Write-Error $errorMessage
    throw $errorMessage
  }
}

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
param(
  [string] $packageName, 
  [string] $fileType = 'exe',
  [string] $silentArgs = '',
  [string] $url,
  [string] $url64bit = $url,
  [string] $validExitCodes = @(0)
)
  
  try {
    $chocTempDir = Join-Path $env:TEMP "chocolatey"
    $tempDir = Join-Path $chocTempDir "$packageName"
    if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
    $file = Join-Path $tempDir "$($packageName)Install.$fileType"
  
    Get-ChocolateyWebFile $packageName $file $url $url64bit
    Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $file -validExitCodes $validExitCodes
    Write-ChocolateySuccess $packageName
  } catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
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

.PARAMETER Url64bit
OPTIONAL - If there is an x64 installer to download, please include it here. If not, delete this parameter

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
param(
  [string] $packageName, 
  [string] $url,
  [string] $unzipLocation,
  [string] $url64bit = $url
)

  try {
    $fileType = 'zip'
    
    $chocTempDir = Join-Path $env:TEMP "chocolatey"
    $tempDir = Join-Path $chocTempDir "$packageName"
    if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
    $file = Join-Path $tempDir "$($packageName)Install.$fileType"
    
    Get-ChocolateyWebFile $packageName $file $url $url64bit
    Get-ChocolateyUnzip "$file" $unzipLocation
    
    Write-ChocolateySuccess $packageName
  } catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw 
  }
}

function Install-ChocolateyPowershellCommand {
param(
  [string] $packageName,
  [string] $psFileFullPath, 
  [string] $url ='',
  [string] $url64bit = $url
)

  try {

    if ($url -ne '') {
      Get-ChocolateyWebFile $packageName $psFileFullPath $url $url64bit
    }

    $nugetPath = $(Split-Path -parent $(Split-Path -parent $helpersPath))
    $nugetExePath = Join-Path $nuGetPath 'bin'
    
    $cmdName = [System.IO.Path]::GetFileNameWithoutExtension($psFileFullPath)
    $packageBatchFileName = Join-Path $nugetExePath "$($cmdName).bat"

    Write-Host "Adding $packageBatchFileName and pointing it to powershell command $psFileFullPath"
"@echo off
powershell -NoProfile -ExecutionPolicy unrestricted -Command ""& `'$psFileFullPath`'  %*"""| Out-File $packageBatchFileName -encoding ASCII 
 
    Write-ChocolateySuccess $packageName
  } catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
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
param(
  [string] $packageName,
  [string] $fileFullPath,
  [string] $url,
  [string] $url64bit = $url
)
  
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
  if ($url.StartsWith('http')) {
    Get-WebFile $url $fileFullPath
  } else {
    Copy-Item $url -Destination $fileFullPath -Force
  }
  
  Start-Sleep 2 #give it a sec or two to finish up
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
param(
  [string] $packageName, 
  [string] $fileType = 'exe',
  [string] $silentArgs = '',
  [string] $file,
  [string] $validExitCodes = @(0)
)
  
  $installMessage = "Installing $packageName..."
  write-host $installMessage

  $additionalInstallArgs = $env:chocolateyInstallArguments;
  if ($additionalInstallArgs -eq $null) { $additionalInstallArgs = ''; }
  $overrideArguments = $env:chocolateyInstallOverride;
    
  if ($fileType -like 'msi') {
    $msiArgs = "/i `"$file`"" 
    if ($overrideArguments) { 
      $msiArgs = "$msiArgs $additionalInstallArgs";
      write-host "Overriding package arguments with `'$additionalInstallArgs`'";
    } else {
      $msiArgs = "$msiArgs $silentArgs $additionalInstallArgs";
    }
    
    Start-ChocolateyProcessAsAdmin "$msiArgs" 'msiexec' -validExitCodes $validExitCodes
    #Start-Process -FilePath msiexec -ArgumentList $msiArgs -Wait
  }
  if ($fileType -like 'exe') {
    if ($overrideArguments) {
      Start-ChocolateyProcessAsAdmin "$additionalInstallArgs" $file -validExitCodes $validExitCodes
      write-host "Overriding package arguments with `'$additionalInstallArgs`'";
    } else {
      Start-ChocolateyProcessAsAdmin "$silentArgs $additionalInstallArgs" $file -validExitCodes $validExitCodes
    }
  }

  write-host "$packageName has been installed."
  #cutStart-Sleep 3
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

function Write-ChocolateySuccess {
param(
  [string] $packageName
)

  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "$packageName"
  if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
  
  $errorLog = Join-Path $tempDir 'failure.log'
  try {
    if ([System.IO.File]::Exists($errorLog)) {[System.IO.File]::Move($errorLog,(Join-Path ($errorLog) '.old'))}
  } catch {
    Write-Error "Could not rename `'$errorLog`' to `'$($errorLog).old`': $($_.Exception.Message)"
  }
  
  $logFile = Join-Path $tempDir 'success.log'
  #Write-Host "Writing to $logFile"

  $successMessage = "$packageName has finished succesfully! The chocolatey gods have answered your request!"
  $successMessage | Out-File -FilePath $logFile -Force -Append
  Write-Host $successMessage
  
  #cutStart-Sleep 7
}

function Write-ChocolateyFailure {
param(
  [string] $packageName,
  [string] $failureMessage
)

  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "$packageName"
  if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
	$successLog = Join-Path $tempDir 'success.log'
  try {
    if ([System.IO.File]::Exists($successLog)) {[System.IO.File]::Move($successLog,(Join-Path ($successLog) '.old'))}
  } catch {
    Write-Error "Could not rename `'$successLog`' to `'$($successLog).old`': $($_.Exception.Message)"
  }
	
  $logFile = Join-Path $tempDir 'failure.log'
  #Write-Host "Writing to $logFile"
	
	$errorMessage = "$packageName did not finish successfully. Boo to the chocolatey gods!
-----------------------
[ERROR] $failureMessage
-----------------------" 
	$errorMessage | Out-File -FilePath $logFile -Force -Append
	Write-Error $errorMessage
	
	#cutStart-Sleep 8
}

function Install-ChocolateyPath {
param(
  [string] $pathToInstall,
  [System.EnvironmentVariableTarget] $pathType = [System.EnvironmentVariableTarget]::User
)

  #get the PATH variable
  $envPath = $env:PATH
  #$envPath = [Environment]::GetEnvironmentVariable('Path', $pathType)
  if (!$envPath.ToLower().Contains($pathToInstall.ToLower()))
  {
    Write-Host "PATH environment variable does not have $pathToInstall in it. Adding..."
    $actualPath = [Environment]::GetEnvironmentVariable('Path', $pathType)

    $statementTerminator = ";"
    #does the path end in ';'?
    $hasStatementTerminator = $actualPath -ne $null -and $actualPath.EndsWith($statementTerminator)
    # if the last digit is not ;, then we are adding it
    If (!$hasStatementTerminator -and $actualPath -ne $null) {$pathToInstall = $statementTerminator + $pathToInstall}
    if (!$pathToInstall.EndsWith($statementTerminator)) {$pathToInstall = $pathToInstall + $statementTerminator}
    $actualPath = $actualPath + $pathToInstall

    if ($pathType -eq [System.EnvironmentVariableTarget]::Machine) {
      $psArgs = "[Environment]::SetEnvironmentVariable('Path',`'$actualPath`', `'$pathType`')"
      Start-ChocolateyProcessAsAdmin "$psArgs"
    } else {
      [Environment]::SetEnvironmentVariable('Path', $actualPath, $pathType)
    }    
    
    #add it to the local path as well so users will be off and running
    $envPSPath = $env:PATH
    $env:Path = $envPSPath + $statementTerminator + $pathToInstall
  }
}

function Install-ChocolateyDesktopLink {
param(
  [string] $targetFilePath
)

  if (test-path($targetFilePath)) {
    $desktop = $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))
    $link = Join-Path $desktop "$([System.IO.Path]::GetFileName($targetFilePath)).lnk"
    $workingDirectory = $([System.IO.Path]::GetDirectoryName($targetFilePath))
    
    $wshshell = New-Object -ComObject WScript.Shell
    $lnk = $wshshell.CreateShortcut($link )
    $lnk.TargetPath = $targetFilePath
    $lnk.WorkingDirectory = $workingDirectory
    $lnk.Save()
    Write-Host "`'$targetFilePath`' has been linked as a shortcut on your desktop"
  } else {
    $errorMessage = "`'$targetFilePath`' does not exist, not able to create a link"
    Write-Error $errorMessage
    throw $errorMessage
  }
}

function Write-Host {
param(
  [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true)][object]$Object,
  [Parameter()][switch] $NoNewLine, 
  [Parameter(Mandatory=$false)][ConsoleColor] $ForegroundColor, 
  [Parameter(Mandatory=$false)][ConsoleColor] $BackgroundColor,
  [Parameter(Mandatory=$false)][Object] $Separator
)

  $chocoPath = (Split-Path -parent $helpersPath)
  $chocoInstallLog = Join-Path $chocoPath 'chocolateyInstall.log'
  $Object | Out-File -FilePath $chocoInstallLog -Force -Append

  $oc = Get-Command 'Write-Host' -Module 'Microsoft.PowerShell.Utility' 
  #I owe this guy a drink - http://powershell.com/cs/blogs/tobias/archive/2011/08/03/clever-splatting-to-pass-optional-parameters.aspx
  & $oc @PSBoundParameters
}

function Write-Error {
param(
  [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][string]$Message='',
  [Parameter(Mandatory=$false)][System.Management.Automation.ErrorCategory]$Category,
  [Parameter(Mandatory=$false)][string]$ErrorId,
  [Parameter(Mandatory=$false)][object]$TargetObject,
  [Parameter(Mandatory=$false)][string]$CategoryActivity,
  [Parameter(Mandatory=$false)][string]$CategoryReason,
  [Parameter(Mandatory=$false)][string]$CategoryTargetName,
  [Parameter(Mandatory=$false)][string]$CategoryTargetType,
  [Parameter(Mandatory=$false)][string]$RecommendedAction
)

  $chocoPath = (Split-Path -parent $helpersPath)
  $chocoInstallLog = Join-Path $chocoPath 'chocolateyInstall.log'
  "[ERROR] $Message" | Out-File -FilePath $chocoInstallLog -Force -Append

  $oc = Get-Command 'Write-Error' -Module 'Microsoft.PowerShell.Utility' 
  & $oc @PSBoundParameters
}

Export-ModuleMember -Function Start-ChocolateyProcessAsAdmin, Install-ChocolateyPackage, Install-ChocolateyZipPackage, Install-ChocolateyPowershellCommand, Get-ChocolateyWebFile, Install-ChocolateyInstallPackage, Get-ChocolateyUnzip, Write-ChocolateySuccess, Write-ChocolateyFailure, Install-ChocolateyPath, Install-ChocolateyDesktopLink, Write-Host, Write-Error

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
  #to check if a proxy is required
  $webclient = new-object System.Net.WebClient
  if (!$webclient.Proxy.IsBypassed($url))
  {
    $cred = get-credential
    $proxyaddress = $webclient.Proxy.GetProxy($url).Authority
    Write-host "Using this proxyserver: $proxyaddress"
    $proxy = New-Object System.Net.WebProxy($proxyaddress)
    $proxy.credentials = $cred.GetNetworkCredential();
    $req.proxy = $proxy
  }
 
  #http://stackoverflow.com/questions/518181/too-many-automatic-redirections-were-attempted-error-message-when-using-a-httpw
  $req.CookieContainer = New-Object System.Net.CookieContainer
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
