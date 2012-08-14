function Get-Sources
{
	$userSources = Get-UserConfigValue "sources"				
	$globalSources = Get-GlobalConfigValue "sources"
				
	if( $userSources -eq $null -or $userSources -eq '')
	{
		$globalSources.selectNodes("//source")
	}
	else
	{
		$allSources = $userSources.selectNodes("//source") + $globalSources.selectNodes("//source")
		
		# filter out all the disabled sources
		$allSources | Where-Object { $userSources.selectSingleNode("//disabled[@id='"+ $_.id + "']") -eq $null}
	}
}
