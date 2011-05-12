param($installPath, $toolsPath, $package, $project)

$modules = Get-ChildItem $ToolsPath -Filter *.psm1
$modules | ForEach-Object { import-module -name  $_.FullName }

@"
========================
NuGet Package Updater
========================
This applies a global update of packages to your solution. 
Every project that is using a package is upgraded to the latest.
Please run 'Update-Package' to upgrade all packages to current version. 
Please run 'Update-Package packageName' to upgrade just one package. 
========================
"@ | Write-Host