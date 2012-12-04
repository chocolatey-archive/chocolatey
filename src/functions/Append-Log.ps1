function Append-Log{
param(
  [string] $chocoInstallLog = ''
)
  Write-Debug "Running 'Remove-LastInstallLog' with chocoInstallLog:`'$chocoInstallLog`'";
  
  if ($chocoInstallLog -eq '') {
    $chocoInstallLog = (Join-Path $nugetChocolateyPath 'chocolateyInstall.log')
  }
  
$header =
@"
$(get-date -format 'yyyyMMdd-HH:mm:ss') [CHOCO] ################################################################################
$(get-date -format 'yyyyMMdd-HH:mm:ss') [CHOCO] #                  Going Chocolatey on $(Get-Date -Format u)                    #
$(get-date -format 'yyyyMMdd-HH:mm:ss') [CHOCO] ################################################################################
"@

  try {
    write-output $header | out-file -append $chocoInstallLog }
  catch {Write-Error "Could not delete `'$chocoInstallLog`': $($_.Exception.Message)"}
}