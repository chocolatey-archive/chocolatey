function Delete-ExistingErrorLog {
param(
  [string] $packageName
)
  Write-Debug "Running 'Delete-ExistingErrorLog' for $packageName";

  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "$packageName"
  $failureLog = Join-Path $tempDir 'failure.log'
  Write-Debug "Looking for failure log at `'$failureLog`'"
  if ([System.IO.File]::Exists($failureLog)) {
    Write-Debug "Found the failure log. Deleting it..."
    [System.IO.File]::Delete($failureLog)
  }
}