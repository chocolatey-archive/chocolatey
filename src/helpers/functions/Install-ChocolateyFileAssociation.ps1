function Install-ChocolateyFileAssociation {
param(
  [string] $extension,
  [string] $executable
)
  Write-Debug "Running 'Install-ChocolateyFileAssociation' associating $extension with `'$executable`'";
  if(-not(Test-Path $executable)){
    $errorMessage = "`'$executable`' does not exist, not able to create association"
    Write-Error $errorMessage
    throw $errorMessage
  }
  $extension=$extension.trim()
  if(-not($extension.StartsWith("."))) {
      $extension = ".$extension"
  }
  $fileType = Split-Path $executable -leaf
  $fileType = $fileType.Replace(" ","_")
  $elevated = "cmd /c 'assoc $extension=$fileType';cmd /c 'ftype $fileType=\`"$executable\`" \`"%1\`" \`"%*\`"'"
  Start-ChocolateyProcessAsAdmin $elevated
  Write-Host "`'$extension`' has been associated with `'$executable`'"
}