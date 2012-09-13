function Install-ChocolateyPinnedTaskBarItem {
param(
  [string] $targetFilePath
)

  Write-Debug "Running 'Install-ChocolateyPinnedTaskBarItem' with targetFilePath:`'$targetFilePath`'";
  
  if (test-path($targetFilePath)) {
    $verb = "Pin To Taskbar"
    $path= split-path $targetFilePath 
    $shell=new-object -com "Shell.Application"  
    $folder=$shell.Namespace($path)    
    $item = $folder.Parsename((split-path $targetFilePath -leaf)) 
    $itemVerb = $item.Verbs() | ? {$_.Name.Replace("&","") -eq $verb} 
    if($itemVerb -eq $null){ 
      $errorMessage = "TaskBar verb not found for $item. It may have already been pinned"
    } else { 
        $itemVerb.DoIt() 
    } 
    Write-Host "`'$targetFilePath`' has been pinned to the task bar on your desktop"
  } else {
    $errorMessage = "`'$targetFilePath`' does not exist, not able to pin to task bar"
  }
  if($errorMessage){
    Write-Error $errorMessage
    throw $errorMessage
  }
}