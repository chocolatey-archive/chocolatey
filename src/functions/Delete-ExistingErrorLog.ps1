function Delete-ExistingErrorLog {
param(
  [string] $packageName
)

  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "$packageName"
  $failureLog = Join-Path $tempDir 'failure.log'
  if ([System.IO.File]::Exists($failureLog)) {
    [System.IO.File]::Delete($failureLog)
  }
}