function Chocolatey-Help {
  $script:chocolatey_help_was_called = $true
  
  Write-Host 'help text here'
  
  if ($script:exec_chocolatey_help_actual) { Chocolatey-Help-Actual @PSBoundParameters}
}