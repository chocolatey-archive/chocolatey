function Get-SourceArgument {
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
			$sources = Get-ConfigValue 'sources'
	
			foreach ($sourceEntry in $sources.ChildNodes) {
				$srcUri = $sourceEntry.value
				$srcArgs = $srcArgs + "-Source `"$srcUri`" "
			}
		}
	}
	
	Write-Debug "Source args: $srcArgs"

	$srcArgs
}