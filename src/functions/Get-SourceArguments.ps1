function Get-SourceArguments {
param(
  [string] $source = ''
)
  $srcArgs = ""
  if ($source -ne '') {
    $srcArgs = "-Source `"$source`""
  }
  else
  {
    $useNugetConfig = Get-ConfigValue 'useNuGetForSources'

    if ($useNugetConfig -eq 'false') {
      $srcArgs = '-Source "'
      $sources = Get-Sources

      $sources | foreach {
        $srcUri = $_.value
        $srcArgs += "$srcUri;"
      }

      $srcArgs += '"'
    }
  }

  Write-Debug "Using `'$srcArgs`' as the source arguments"

  return $srcArgs
}
