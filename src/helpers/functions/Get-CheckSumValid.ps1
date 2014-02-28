function Get-CheckSumValid {
param(
  [string] $file,
  [string] $checkSum = ''
)
  Write-Debug "Running 'Get-CheckSumValid' with file:`'$file`', checkSum: `'$checkSum`'";
  if ($checkSum -eq '' -or $checkSum -eq $null) { return }

  # On first install, env:ChocolateyInstall might be null still - join-path has issues
  $md5 = Join-Path "$env:SystemDrive" 'chocolatey\chocolateyinstall\tools\md5.exe'
  if ($env:ChocolateyInstall){
    $md5 = Join-Path "$env:ChocolateyInstall" 'chocolateyinstall\tools\md5.exe'
  }

  Write-Debug "Calling command [`'$md5`' -c$checkSum `"$file`"] to retrieve checksum"
  $process = Start-Process "$md5" -ArgumentList " -c$checkSum `"$file`"" -Wait -WindowStyle Hidden -PassThru
  #-OutVariable md5Output

  Write-Debug "`'$md5`' exited with $($process.ExitCode)"

  if ($process.ExitCode -ne 0) {
    throw "CheckSum for `'$file'` did not meet `'$checkSum`'."
  }

  #$fileCheckSumActual = $md5Output.Split(' ')[0]
  # if ($fileCheckSumActual -ne $checkSum) {
  #   throw "CheckSum for `'$file'` did not meet `'$checkSum`'."
  # }
}
