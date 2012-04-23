function Get-PackageFolderVersions {
param(
  [string] $packageName = ''
)

  $packageFolders = Get-PackageFoldersForPackage $packageName
  $packageVersions = @()
  foreach ($packageFolder in $packageFolders) {
    $packageVersions = $packageVersions + $packageFolder.Name -replace "$packageName\."
  }
 
  return Get-VersionsForComparison $packageVersions
}