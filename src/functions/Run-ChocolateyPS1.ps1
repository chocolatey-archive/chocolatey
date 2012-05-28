function Run-ChocolateyPS1 {
param([string] $packageFolder, [string] $packageName, [string] $action)


	  switch ($action) 
	{
	  "install" { $actionFile = "chocolateyinstall.ps1"; }
	  "uninstall" {$actionFile = "chocolateyuninstall.ps1"; }
	  default { $actionFile = "chocolateyinstall.ps1";}
	}

  if ($packageFolder -notlike '') { 
@"
$h2
Chocolatey $action ($actionFile)
$h2
Looking for $actionFile in folder $packageFolder
If $actionFile is found, it will be run.
$h2
"@ | Write-Host

    $ps1 = Get-ChildItem  $packageFolder -recurse | ?{$_.name -match $actionFile} | sort name -Descending | select -First 1
    
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
