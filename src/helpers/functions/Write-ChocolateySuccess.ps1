function Write-ChocolateySuccess {
param(
  [string] $packageName
)

  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "$packageName"
  if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
  
  $errorLog = Join-Path $tempDir 'failure.log'
  try {
    if ([System.IO.File]::Exists($errorLog)) {
      $oldErrorLog = Join-Path "$errorLog" '.old'
      Move-Item $errorLog $oldErrorLog -Force
      #[System.IO.File]::Move($errorLog,(Join-Path ($errorLog) '.old'))
    }
  } catch {
    Write-Error "Could not rename `'$errorLog`' to `'$($errorLog).old`': $($_.Exception.Message)"
  }
  
  $logFile = Join-Path $tempDir 'success.log'
  #Write-Host "Writing to $logFile"

  $successMessage = "$packageName has finished succesfully! The chocolatey gods have answered your request!"
  $successMessage | Out-File -FilePath $logFile -Force -Append
  Write-Host $successMessage
}