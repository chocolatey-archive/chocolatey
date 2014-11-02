function Chocolatey-Push {
param(
  [string] $packageName,
  [string] $source = 'https://chocolatey.org/'
)
  Write-Debug "Running 'Chocolatey-Push' for $packageName with source:`'$source`'";

  $srcArgs = "-source $source"
  if ($source -like '') {
    $srcArgs = '-source https://chocolatey.org/'
    Write-Debug "Setting source to `'$srcArgs`'"
  }

  $packageArgs = "push $packageName $srcArgs -NonInteractive"
  $logFile = Join-Path $nugetChocolateyPath 'push.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'

  Write-Host "Calling `'$nugetExe $packageArgs`'. This may take a few minutes. Please wait for the command to finish."  -ForegroundColor $Note -BackgroundColor Black

  $process = Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile -PassThru
  # this is here for specific cases in Posh v3 where -Wait is not honored
  try { if (!($process.HasExited)) { Wait-Process -Id $process.Id } } catch { }

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    Write-Host $line -ForegroundColor $Note -BackgroundColor Black
  }
  $errors = Get-Content $errorLogFile
  if ($process.ExitCode -ne 0) {
    throw $errors
  }

  if ($source -like '' -or $source -like 'https://chocolatey.org/') {
@"
Your package may be subject to moderation. A moderator will review the
package prior to acceptance. You should have received an email. If you
don't hear back from moderators within one business day, please reply
to the email and ask for status or use contact site admins on the
package page to contact moderators.

Please ensure your registered email address is correct and emails from
chocolateywebadmin at googlegroups dot com are not being sent to your
spam/junk folder.
"@ | Write-Host  -ForegroundColor $Warning -BackgroundColor Black

  }
}
