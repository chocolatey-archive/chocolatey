function Invoke-ChocolateyFunction ($ChocoFunction,$paramlist) {
  try {invoke-expression "$ChocoFunction @paramlist;"}
  catch {Write-Host $_.exception.message -BackgroundColor Red -ForegroundColor White ;exit 1}
}