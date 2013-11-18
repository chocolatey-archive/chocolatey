function Get-ChocolateyBins {
param(
  [string] $packageFolder,
  [switch] $uninstall
)
  Write-Debug "Running 'Get-ChocolateyBins' for $packageFolder";

  if ($packageFolder -notlike '') {

    Write-Debug "  __ Executable Links (*.exe) __"
@"
Looking for executables in folder: $packageFolder
Adding batch files for any executables found to a location on PATH. In other words the executable will be available from ANY command line/powershell prompt.
"@ | Write-Debug
    $batchCreated = $false
    try {
      $files = get-childitem $packageFolder -include *.exe -recurse
      if ($files -ne $null) { Write-Debug "Found $($files.Count) exe files to possibly generate." }
      foreach ($file in $files) {
        Write-Debug "Found '$file' for batch redirect"
        if (!(test-path($file.FullName + '.ignore'))) {
          if (test-path($file.FullName + '.gui')) {
            if ($uninstall) {
              Remove-BinFile $file.Name.Replace(".exe","").Replace(".EXE","") $file.FullName
            } else {
              Generate-BinFile $file.Name.Replace(".exe","").Replace(".EXE","") $file.FullName -useStart
            }
          } else {
            if ($uninstall) {
              Remove-BinFile $file.Name.Replace(".exe","").Replace(".EXE","") $file.FullName
            } else {
              Generate-BinFile $file.Name.Replace(".exe","").Replace(".EXE","") $file.FullName
            }
          }
          $batchCreated = $true
        }
      }
    }
    catch {
      #Write-Host 'There are no executables (that are not ignored) in the package.'
    }

    if (!($batchCreated)) {
      Write-Debug 'There are no executables (that are not ignored) in the package.'
    }

  }
}
