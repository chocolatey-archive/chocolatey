function Invoke-ChocolateyFunction ($ChocoFunction,$paramlist) {
  try {
  	Write-Debug "Invoke-ChocolateyFunction is calling: `$ChocoFunction='$ChocoFunction'|`@paramlist='@paramlist'"
  	invoke-expression "$ChocoFunction @paramlist;"
  }
  #catch {Write-Host $_.exception.message -BackgroundColor Red -ForegroundColor White ;exit 1}
  catch {
    Write-Debug "Caught `'$_`'"
    throw "$($_.Exception.Message)"
  }
}
