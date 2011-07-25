$chocInstallVariableName = "ChocolateyInstall"
$sysDrive = $env:SystemDrive
$defaultNugetPath = "$sysDrive\NuGet"

function Set-ChocolateyInstallFolder($folder){
  if(test-path $folder){
    [Environment]::SetEnvironmentVariable($chocInstallVariableName, $folder, [System.EnvironmentVariableTarget]::User)
  }
  else{
    throw "Cannot set the chocolatey install folder. Folder not found [$folder]"
  }
}

function Get-ChocolateyInstallFolder(){
  [Environment]::GetEnvironmentVariable($chocInstallVariableName, [System.EnvironmentVariableTarget]::User)
}

function Create-DirectoryIfNotExists($folderName){
  if (![System.IO.Directory]::Exists($folderName)) {[System.IO.Directory]::CreateDirectory($folderName)}
}

function Create-ChocolateyBinFiles {
param([string] $nugetChocolateyPath,[string] $nugetExePath)

$nugetChocolateyBinFile = Join-Path $nugetExePath 'chocolatey.bat'
$nugetChocolateyInstallAlias = Join-Path $nugetExePath 'cinst.bat'
$nugetChocolateyInstallIfMissingAlias = Join-Path $nugetExePath 'cinstm.bat'
$nugetChocolateyUpdateAlias = Join-Path $nugetExePath 'cup.bat'
$nugetChocolateyListAlias = Join-Path $nugetExePath 'clist.bat'
$nugetChocolateyVersionAlias = Join-Path $nugetExePath 'cver.bat'

Write-Host "Creating `'$nugetChocolateyBinFile`' so you can call 'chocolatey' from anywhere."
"@echo off
""$nugetChocolateyPath\chocolatey.cmd"" %*" | Out-File $nugetChocolateyBinFile -encoding ASCII
Write-Host "Creating `'$nugetChocolateyInstallAlias`' so you can call 'chocolatey install' from a shortcut of 'cinst'."
"@echo off
""$nugetChocolateyPath\chocolatey.cmd"" install %*" | Out-File $nugetChocolateyInstallAlias -encoding ASCII
Write-Host "Creating `'$nugetChocolateyInstallIfMissingAlias`' so you can call 'chocolatey installmissing' from a shortcut of 'cinstm'."
"@echo off
""$nugetChocolateyPath\chocolatey.cmd"" installmissing %*" | Out-File $nugetChocolateyInstallIfMissingAlias -encoding ASCII
Write-Host "Creating `'$nugetChocolateyUpdateAlias`' so you can call 'chocolatey update' from a shortcut of 'cup'."
"@echo off
""$nugetChocolateyPath\chocolatey.cmd"" update %*" | Out-File $nugetChocolateyUpdateAlias -encoding ASCII
Write-Host "Creating `'$nugetChocolateyListAlias`' so you can call 'chocolatey list' from a shortcut of 'clist'."
"@echo off
""$nugetChocolateyPath\chocolatey.cmd"" list %*" | Out-File $nugetChocolateyListAlias -encoding ASCII
Write-Host "Creating `'$nugetChocolateyVersionAlias`' so you can call 'chocolatey version' from a shortcut of 'cver'."
"@echo off
""$nugetChocolateyPath\chocolatey.cmd"" version %*" | Out-File $nugetChocolateyVersionAlias -encoding ASCII
}

function Initialize-Chocolatey {
<#
	.DESCRIPTION
		This will initialize the Chocolatey tool by
			a) setting up the "nugetPath" (the location where all chocolatey nuget packages will be installed)
			b) Installs chocolatey into the "nugetPath"
			c) Adds chocolaty to the PATH environment variable so you have access to the chocolatey|cinst commands.
	.PARAMETER  NuGetPath
		Allows you to override the default path of (C:\NuGet\) by specifying a directory chocolaty will install nuget packages.

	.EXAMPLE
		C:\PS> Initialize-Chocolatey

		Installs chocolatey into the default C:\NuGet\ directory.

	.EXAMPLE
		C:\PS> Initialize-Chocolatey -nugetPath "D:\ChocolateyInstalledNuGets\"

		Installs chocolatey into the custom directory D:\ChocolateyInstalledNuGets\

#>
param(
  [Parameter(Mandatory=$false)]
  [string]$nugetPath = "$sysDrive\NuGet"
)

  if(!(test-path $nugetPath)){
    mkdir $nugetPath | out-null
  }
  
	#if we have an already environment variable path, use it.
	$alreadyInitializedNugetPath = Get-ChocolateyInstallFolder
  if($alreadyInitializedNugetPath -and $alreadyInitializedNugetPath -ne $nugetPath){
    $nugetPath = $alreadyInitializedNugetPath
  }
  else {
		#if we are just using the default, don't create the environment variable
		if ($nugetPath -ne $defaultNugetPath) {
			Set-ChocolateyInstallFolder $nugetPath
		}
  }

  #set up variables to add
  $statementTerminator = ";"
  $nugetExePath = Join-Path $nuGetPath 'bin'
  $nugetLibPath = Join-Path $nuGetPath 'lib'
  $nugetChocolateyPath = Join-Path $nuGetPath 'chocolateyInstall'

  $nugetYourPkgPath = [System.IO.Path]::Combine($nugetLibPath,"yourPackageName")
@"
We are setting up the Chocolatey repository for NuGet packages that should be at the machine level. Think executables/application packages, not library packages.
That is what Chocolatey NuGet goodness is for.
The repository is set up at `'$nugetPath`'.
The packages themselves go to `'$nugetLibPath`' (i.e. $nugetYourPkgPath).
A batch file for the command line goes to `'$nugetExePath`' and points to an executable in `'$nugetYourPkgPath`'.

Creating Chocolatey NuGet folders if they do not already exist.

"@ | Write-Host

  #create the base structure if it doesn't exist
  Create-DirectoryIfNotExists $nugetExePath
  Create-DirectoryIfNotExists $nugetLibPath
  Create-DirectoryIfNotExists $nugetChocolateyPath

  #$chocInstallFolder = Get-ChildItem .\ -Recurse | ?{$_.name -match  "chocolateyInstall*"} | sort name -Descending | select -First 1 
  $thisScript = (Get-Variable MyInvocation -Scope 1).Value 
  $thisScriptFolder = Split-Path $thisScript.MyCommand.Path
  $chocInstallFolder = Join-Path $thisScriptFolder "chocolateyInstall"
  Write-Host "Copying the contents of `'$chocInstallFolder`' to `'$nugetPath`'."
  Copy-Item $chocInstallFolder $nugetPath -recurse -force

  Create-ChocolateyBinFiles $nugetChocolateyPath $nugetExePath
  Write-Host ''
    
  #get the PATH variable
  $envPath = $env:PATH
  
  #if you do not find $nugetPath\bin, add it 
  if (!$envPath.ToLower().Contains($nugetExePath.ToLower()))
  {
    Write-Host ''
    #now we update the path
    Write-Host 'PATH environment variable does not have ' $nugetExePath ' in it. Adding.'
		$userPath = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
  
    #does the path end in ';'?
    $hasStatementTerminator= $userPath.EndsWith($statementTerminator)
    # if the last digit is not ;, then we are adding it
    If (!$hasStatementTerminator) {$nugetExePath = $statementTerminator + $nugetExePath}
    $userPath = $userPath + $nugetExePath + $statementTerminator

    [Environment]::SetEnvironmentVariable('Path', $userPath, [System.EnvironmentVariableTarget]::User)

		#add it to the local path as well so users will be off and running
		$envPSPath = $env:PATH
		$env:Path = $envPSPath + $statementTerminator + $nugetExePath + $statementTerminator
	}

@"
Chocolatey is now ready.
You can call chocolatey from anywhere, command line or powershell by typing chocolatey.
Run chocolatey /? for a list of functions.
"@ | write-host
}

export-modulemember -function Initialize-Chocolatey;