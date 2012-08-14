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
			$sources = Get-Sources
	
			foreach ($source in $sources) {
				$srcUri = $source.value
				$srcArgs = $srcArgs + "-Source `"$srcUri`" "
			}
		}
	}
	
	Write-Debug "Using `'$srcArgs`' as the source arguments"

	return $srcArgs
}
