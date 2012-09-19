function Update-SessionEnvironment {

  $script:update_sessionenvironment_was_called = $true
  
  if ($script:exec_update_sessionenvironment_actual) { Update-SessionEnvironment-Actual}
}