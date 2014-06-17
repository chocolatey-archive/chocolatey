function Chocolatey-WindowsFeatures {
param(
  [string] $packageName
)
  Write-Debug "Running 'Chocolatey-WindowsFeatures' for $packageName";


  Write-Host "Chocolatey (v$chocVer) is installing $packageName and dependencies (from Windows Features). By installing you accept the license for $packageName and each dependency you are installing." -ForegroundColor $RunNote -BackgroundColor Black

  $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWindowsFeaturesInstall.log';
  Append-Log $chocoInstallLog

  # On a 64-bit OS, the 32-bit version of DISM can be called if the powershell host is 32-bit and results in an error...
  # This is due to the file system redirector. To fix this we just need to use the "sysnative" directory to force 32 bit processes
  #  to fetch items in the real system32 directory and not in SysWOW64.
  $dism = "$env:WinDir\System32\dism.exe"
  if (Test-Path "$env:WinDir\sysnative\dism.exe") {
    $dism = "$env:WinDir\sysnative\dism.exe"
  }

  $checkStatement=@"
`$dismInfo=(cmd /c `"$dism /Online /Get-FeatureInfo /FeatureName:$packageName`")
if(`$dismInfo -contains 'State : Enabled') {return}
if(`$dismInfo -contains 'State : Enable Pending') {return}
"@

  $osVersion = (Get-WmiObject -class Win32_OperatingSystem).Version

  $packageArgs = "/c $dism /Online /NoRestart /Enable-Feature"
  if($osVersion -ge 6.2) {
    $packageArgs += " /all"
  }
  $packageArgs += " /FeatureName:$packageName"

  Write-Host "Opening minimized PowerShell window and calling `'cmd.exe $packageArgs`'. If progress is taking a long time, please check that window. It also may not be 100% silent..." -ForegroundColor $Warning -BackgroundColor Black
  $statements = $checkStatement + "`ncmd.exe $packageArgs | Tee-Object -FilePath `'$chocoInstallLog`';"
  Start-ChocolateyProcessAsAdmin "$statements" -minimized -nosleep -validExitCodes @(0,1)

  Create-InstallLogIfNotExists $chocoInstallLog
  $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
  foreach ($line in $installOutput) {
    Write-Host $line
  }
  if($installOutput.Count -eq 0) {
    Write-Host "`'$packageName`' has already been installed - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
  }
  else {
    Write-Host "Finished installing `'$packageName`' and dependencies - if errors not shown in console, none detected. Check log for errors if unsure." -ForegroundColor $RunNote -BackgroundColor Black
  }
}
