function Write-UserConfig ($writeOperation)
{
  $userConfigFile = Join-Path $env:USERPROFILE chocolatey.config

  # check to see if there is a user config file
  if ( -not(Test-Path($userConfigFile)) )
  {
    # Create an empty user config file
    New-Item $userConfigFile -ItemType file -Value '<?xml version="1.0"?><chocolatey><sources></sources></chocolatey>' | Out-Null
  }

  $userConfig = [xml] (Get-Content $userConfigFile)

  $save = . $writeOperation $userConfig
  if($save)
  {
    $userConfig.Save($userConfigFile)
  }
}
