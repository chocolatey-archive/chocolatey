function Remove-BinFile {
param(
  [string] $name, 
  [string] $path
)
  Write-Debug "Running 'Remove-BinFile' for $name with path:`'$path`'";

  $packageBatchFileName = Join-Path $nugetExePath "$name.bat"
  $packageBashFileName = Join-Path $nugetExePath "$name"
  $path = $path.ToLower().Replace($nugetPath.ToLower(), "%DIR%..\").Replace("\\","\")
  $pathBash = $path.Replace("%DIR%..\","`$DIR/../").Replace("\","/")
  Write-Debug "Attempting to remove the batch and bash shortcuts: $packageBatchFileName and $packageBashFileName"
  if (Test-Path $packageBatchFileName) {
    Write-Host "Removing batch file $packageBatchFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageBatchFileName
  }
  else {
    Write-Host "Tried to remove batch file $packageBatchFileName but it was already removed." -ForegroundColor $Note
  }
  if (Test-Path $packageBashFileName) {
    Write-Host "Removing bash file $packageBashFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageBashFileName
  }
  else {
    Write-Host "Tried to remove bash file $packageBashFileName but it was already removed." -ForegroundColor $Note
  }
}
