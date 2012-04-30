function Chocolatey-Update {
param(
  [string] $packageName ='', 
  [string] $source = ''
)

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  
  $packages = $packageName
  if ($packageName -eq 'all') {
		$packageFolders = Get-ChildItem $nugetLibPath | sort name
		$packages = $packageFolders -replace "(\.\d{1,})+"|gu 
	}

	foreach ($package in $packages) {
		$versions = Chocolatey-Version $package $source
		if ($versions -ne $null -and $versions.'foundCompare' -lt $versions.'latestCompare') {
			Chocolatey-NuGet $package $source
		}
	}
}