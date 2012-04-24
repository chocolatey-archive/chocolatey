function Run-NuGet {
param(
  [string] $packageName, 
  [string] $source,
  [string] $version
)

$fileText = @"
Successfully installed '$packageName 1.0'.
"@
if ($version -ne '') {
   $fileText = @"
Successfully installed '$packageName $version'.
"@
  }

  Setup -File 'chocolatey\chocolateyInstall\install.log' $fileText 
  

  $script:run_nuget_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  $script:version = $version
  
  if ($script:exec_run_nuget_actual) { Run-NuGet-Actual @PSBoundParameters
  } else {
    return $fileText
  }
}