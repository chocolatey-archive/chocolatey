$helpersPath = (Split-Path -parent $MyInvocation.MyCommand.Definition);

$DebugPreference = "SilentlyContinue"
if ($env:ChocolateyEnvironmentDebug -eq 'true') {$DebugPreference = "Continue";}


# grab functions from files
Resolve-Path $helpersPath\functions\*.ps1 | 
    ? { -not ($_.ProviderPath.Contains(".Tests.")) } |
    % { . $_.ProviderPath }

Export-ModuleMember -Function Start-ChocolateyProcessAsAdmin, Install-ChocolateyPackage, Uninstall-ChocolateyPackage, Install-ChocolateyZipPackage, Install-ChocolateyPowershellCommand, Get-ChocolateyWebFile, Install-ChocolateyInstallPackage, Get-ChocolateyUnzip, Write-ChocolateySuccess, Write-ChocolateyFailure, Install-ChocolateyPath, Install-ChocolateyDesktopLink, Install-ChocolateyPinnedTaskBarItem, Install-ChocolateyExplorerMenuItem, Install-ChocolateyFileAssociation, Install-ChocolateyEnvironmentVariable, Write-Host, Write-Debug, Write-Error, Update-SessionEnvironment