function Run-ChocolateyPS1 {
param(
  [string] $packageFolder, 
  [string] $packageName
)

  if ($packageFolder -notlike '') { 
@"
$h2
Chocolatey Installation (chocolateyinstall.ps1)
$h2
Looking for chocolateyinstall.ps1 in folder $packageFolder
If chocolateyInstall.ps1 is found, it will be run.
$h2
"@ | Write-Host

    $ps1 = Get-ChildItem  $packageFolder -recurse | ?{$_.name -match "chocolateyinstall.ps1"} | sort name -Descending | select -First 1
    
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