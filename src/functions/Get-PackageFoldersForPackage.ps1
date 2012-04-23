function Get-PackageFoldersForPackage {
param(
  [string]$packageName = ''
)
  return Get-ChildItem $nugetLibPath | ?{$_.name -match "^$packageName\.\d+"}
}