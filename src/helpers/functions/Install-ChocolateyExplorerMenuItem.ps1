function Install-ChocolateyExplorerMenuItem {
param(
  [string]$menuKey, 
  [string]$menuLabel, 
  [string]$command, 
  [ValidateSet('file','directory')]
  [string]$type = "file"
)
try {
  Write-Debug "Running 'Install-ChocolateyExplorerMenuItem' with menuKey:'$menuKey', menuLabel:'$menuLabel', command:'$command', type '$type'"
  if($type -eq "file") {$key = "*"} elseif($type -eq "directory") {$key="directory"} else{ return 1}
  $elevated = "`
    if( -not (Test-Path -path HKCR:) ) {New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root};`
    if(!(test-path -LiteralPath 'HKCR:\$key\shell\$menuKey')) { new-item -Path 'HKCR:\$key\shell\$menuKey' };`
    Set-ItemProperty -LiteralPath 'HKCR:\$key\shell\$menuKey' -Name '(Default)'  -Value '$menuLabel';`
    if(!(test-path -LiteralPath 'HKCR:\$key\shell\$menuKey\command')) { new-item -Path 'HKCR:\$key\shell\$menuKey\command' };`
    Set-ItemProperty -LiteralPath 'HKCR:\$key\shell\$menuKey\command' -Name '(Default)' -Value '$command \`"%1\`"';`
    return 0;"

  Start-ChocolateyProcessAsAdmin $elevated
  Write-Host "'$menuKey' explorer menu item has been created"
} 
catch {
    $errorMessage = "'$menuKey' explorer menu item was not created $($_.Exception.Message)"
    Write-Error $errorMessage
    throw $errorMessage
  }
}