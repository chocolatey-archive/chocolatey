function Start-ChocolateyProcessAsAdmin {
param(
  [string] $statements, 
  [string] $exeToRun = 'powershell',
  $validExitCodes = @(0)
)

  $wrappedStatements = $statements;
  if ($exeToRun -eq 'powershell') {
    $exeToRun = "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe"
    if (!$statements.EndsWith(';')){$statements = $statements + ';'}
    $importChocolateyHelpers = "";
    Get-ChildItem "$helpersPath" -Filter *.psm1 | ForEach-Object { $importChocolateyHelpers = "& import-module -name  `'$($_.FullName)`';$importChocolateyHelpers" };
    $wrappedStatements = "-NoProfile -ExecutionPolicy unrestricted -Command `"$importChocolateyHelpers try{$statements start-sleep 6;}catch{write-error `'That was not sucessful`';start-sleep 8;throw;}`""
  }
@"
Elevating Permissions and running $exeToRun $wrappedStatements. This may take awhile, depending on the statements.
"@ | Write-Host

  $psi = new-object System.Diagnostics.ProcessStartInfo;
  $psi.FileName = $exeToRun;
  if ($wrappedStatements -ne '') {
    $psi.Arguments = "$wrappedStatements";
  }
  $psi.Verb = "runas";
  $psi.WorkingDirectory = get-location;
 
  $s = [System.Diagnostics.Process]::Start($psi);
  $s.WaitForExit();
  if ($validExitCodes -notcontains $s.ExitCode) {
    $errorMessage = "[ERROR] Running $exeToRun with $statements was not successful. Exit code was `'$($s.ExitCode)`'."
    Write-Error $errorMessage
    throw $errorMessage
  }
}