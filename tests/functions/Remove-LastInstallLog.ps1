function Remove-LastInstallLog{
param(
  [string] $chocoInstallLog
)

  $script:remove_lastinstalllog_was_called = $true
  $script:chocoInstallLog = $chocoInstallLog
  
  if ($script:exec_remove_lastinstalllog_actual) { Remove-LastInstallLog-Actual @PSBoundParameters}
}