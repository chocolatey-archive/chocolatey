function Append-Log{
param(
  [string] $chocoInstallLog = ''
)
  Write-Debug "Running 'Remove-LastInstallLog' with chocoInstallLog:`'$chocoInstallLog`'";
  
  if ($chocoInstallLog -eq '') {
    $chocoInstallLog = (Join-Path $nugetChocolateyPath 'chocolateyInstall.log')
  }
	#try {
  #  if ([System.IO.File]::Exists($chocoInstallLog)) {[System.IO.File]::Delete($chocoInstallLog)}
  #} catch {
  #  Write-Error "Could not delete `'$chocoInstallLog`': $($_.Exception.Message)"
  
$header = @"
################################################################################
#                                                                              #
#                   Going Chocolatey on $(Get-Date -Format u)                  #
#                              (you can go back)                               #
#                                                                              #
################################################################################
"@

write-output $header | out-file -append $chocoInstallLog
  
}