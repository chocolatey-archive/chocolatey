function Run-ChocolateyPS1 {
param(
  [string] $packageFolder, 
  [string] $packageName, 
  [string] $action
)
  Write-Debug "Running 'Run-ChocolateyPS1' for $packageName with packageFolder:`'$packageFolder`', action: `'$action`'";

	  switch ($action) 
	{
	  "install" { $actionFile = "chocolateyinstall.ps1"; }
	  "uninstall" {$actionFile = "chocolateyuninstall.ps1"; }
	  default { $actionFile = "chocolateyinstall.ps1";}
	}

  if ($packageFolder -notlike '') { 
@"
  $h2
   PowerShell $action ($actionFile)
  $h2
"@ | Write-Host
@"
Looking for $actionFile in folder $packageFolder
If $actionFile is found, it will be run.
$h2
"@ | Write-Debug

    $ps1 = Get-ChildItem  $packageFolder -recurse | ?{$_.name -match $actionFile} | sort name -Descending | select -First 1
    $installps1 = Get-ChildItem  $packageFolder -recurse | ?{$_.name -match 'chocolateyinstall.ps1'} | sort name -Descending | select -First 1
    
    Write-Debug "action file is `'$ps1`'"

    if ($ps1 -notlike '') {
      $env:chocolateyInstallArguments = "$installArguments"
      $env:chocolateyInstallOverride = $null
      if ($overrideArgs -eq $true) {
        $env:chocolateyInstallOverride = $true
      } 
      
      $ps1FullPath = $ps1.FullName
      Write-Debug "Running `'$ps1FullPath`'";
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

    if ($installps1 -notlike '' -and $ps1 -like '') {
      Write-Host "This package has a chocolateyInstall.ps1 without a chocolateyUninstall.ps1. You will need to manually reverse whatever steps the installer did. Please ask the package maker to include a chocolateyUninstall.ps1 in the file to really remove the package."
    }
  }
}
