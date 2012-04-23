# Start-Process [-FilePath] <string> [[-ArgumentList] <string[]>] [-Credential <PSCredential>] [-LoadUserProfile] [-NoNewWindow] [-PassThru] [-RedirectStandardError <string>] [-RedirectStandardInput <string>] [-RedirectStandardOutput <string>] [-UseNewEnvironment] [-Wait] [-WorkingDirectory <string>] [<CommonParameters>]

function Start-Process {
param(
  [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false)][string]$FilePath,
  [Parameter(Position=1)][string[]] $ArgumentList, 
  [PSCredential] $Credential, 
  [switch] $LoadUserProfile, 
  [switch] $NoNewWindow, 
  [switch] $PassThru, 
  [string] $RedirectStandardError, 
  [string] $RedirectStandardInput, 
  [string] $RedirectStandardOutput, 
  [switch] $UseNewEnvironment, 
  [switch] $Wait, 
  [string] $WorkingDirectory
)

  $script:start_process_was_called = $true
  $script:FilePath = $FilePath
  $script:ArgumentList = $ArgumentList
  
  if ($script:exec_start_process_actual) { Start-Process-Actual @PSBoundParameters}
}

#Start-Process [-FilePath] <string> [[-ArgumentList] <string[]>] [-PassThru] [-Verb <string>] [-Wait] [-WindowStyle {Normal | Hidden | Minimized | Maximized}] [-WorkingDirectory <string>] [<CommonParameters>]

function Start-Process {
param(
  [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false)][string]$FilePath,
  [Parameter(Position=1)][string[]] $ArgumentList, 
  [switch] $PassThru, 
  [string] $Verb, 
  [switch] $Wait, 
  [{Normal | Hidden | Minimized | Maximized}] $WindowsStyle,
  [string] $WorkingDirectory
)

  $script:start_process_was_called = $true
  $script:FilePath = $FilePath
  $script:ArgumentList = $ArgumentList
  
  if ($script:exec_start_process_actual) { Start-Process-Actual @PSBoundParameters}
}