$helpersPath = (Split-Path -parent $MyInvocation.MyCommand.Definition);

$DebugPreference = "SilentlyContinue"
if ($env:ChocolateyEnvironmentDebug -eq 'true') {$DebugPreference = "Continue";}

# grab functions from files
Get-Item $helpersPath\functions\*.ps1 | 
    ? { -not ($_.Name.Contains(".Tests.")) } |
    % { . $_.FullName;  if ( -not ($_.Name.Contains(".Internal.")))  { Export-ModuleMember -Function $_.BaseName } }
