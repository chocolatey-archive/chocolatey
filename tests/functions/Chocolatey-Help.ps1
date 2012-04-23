function Chocolatey-Help {
  $script:chocolatey_help_was_called = $true
  
  if ($script:exec_chocolatey_help_actual) { Chocolatey-Help-Actual @PSBoundParameters}
}