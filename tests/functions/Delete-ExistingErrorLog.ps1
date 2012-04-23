function Delete-ExistingErrorLog {
param(
  [string] $packageName
)
  
  $script:delete_existingerrorlog_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_delete_existingerrorlog_actual) { Delete-ExistingErrorLog-Actual @PSBoundParameters}
}