function Remove-BinFile {
param(
  [string] $name, 
  [string] $path
)
  Write-Debug "Running 'Remove-BinFile' for $name with path:`'$path`'";

  $packageBatchFileName = Join-Path $nugetExePath "$name.bat"
  $packageBashFileName = Join-Path $nugetExePath "$name"
  $packageShimFileName = Join-Path $nugetExePath "$name.exe"
  $path = $path.ToLower().Replace($nugetPath.ToLower(), "%DIR%..\").Replace("\\","\")
  $pathBash = $path.Replace("%DIR%..\","`$DIR/../").Replace("\","/")
  Write-Debug "Attempting to remove the batch and bash shortcuts: $packageBatchFileName and $packageBashFileName"
  if (Test-Path $packageBatchFileName) {
    Write-Host "Removing batch file $packageBatchFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageBatchFileName
  }
  else {
    Write-Debug "Tried to remove batch file $packageBatchFileName but it was already removed."
  }
  if (Test-Path $packageBashFileName) {
    Write-Host "Removing bash file $packageBashFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageBashFileName
  }
  else {
    Write-Debug "Tried to remove bash file $packageBashFileName but it was already removed."
  }
  Write-Debug "Attempting to remove the shim: $packageShimFileName"
  if (Test-Path $packageShimFileName) {
    Write-Host "Removing shim $packageShimFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageShimFileName
  }
  else {
    Write-Debug "Tried to remove shim $packageShimFileName but it was already removed."
  }
}
