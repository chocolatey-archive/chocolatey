function Get-CheckSumValid {
param(
  [string] $file,
  [string] $checkSum = ''
)
  Write-Debug "Running 'Get-CheckSumValid' with file:`'$file`', checkSum: `'$checkSum`'";


  if ($checkSum -eq '' -or $checkSum -eq $null) { return }

  #todo Get file's actual checksum

  $fileCheckSumActual = $checkSum

  if ($fileCheckSumActual -ne $checkSum) {
    throw "CheckSum for `'$file'` did not meet `'$checkSum`'. Actual value was `'$fileCheckSumActual`'"
  }
}
