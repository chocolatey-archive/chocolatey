function Start-ChocolateyProcessAsAdmin {
param(
  [string] $statements, 
  [string] $exeToRun,
  $validExitCodes = @(0)
)

  $script:start_chocolateyprocessasadmin_was_called = $true
  $script:statements = $statements
  $script:exeToRun = $exeToRun
  $script:validExitCodes = $validExitCodes
  
  if ($script:exec_start_chocolateyprocessasadmin_actual) { Start-ChocolateyProcessAsAdmin-Actual @PSBoundParameters}
}