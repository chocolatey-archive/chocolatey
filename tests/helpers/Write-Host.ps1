#not overwriting this one
function Write-Host-Local {
param(
  [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)][object] $Object,
  [switch] $NoNewLine, 
  [object] $Separator,
  [ConsoleColor] $ForegroundColor, 
  [ConsoleColor] $BackgroundColor
)

  $script:write_host_was_called = $true
  $script:Object = $Object
  $script:NoNewLine = $NoNewLine
  $script:ForegroundColor = $ForegroundColor
  $script:BackgroundColor = $BackgroundColor
  $script:Separator = $Separator
  
  if ($script:exec_write_host_actual) { Write-Host-Actual @PSBoundParameters}
}