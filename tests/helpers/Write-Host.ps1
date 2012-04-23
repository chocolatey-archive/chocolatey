#not overwriting this one
function Write-Host-Local {
param(
  [object] $Object,
  [switch] $NoNewLine, 
  [ConsoleColor] $ForegroundColor, 
  [ConsoleColor] $BackgroundColor,
  [object] $Separator
)

  $script:write_host_was_called = $true
  $script:Object = $Object
  $script:NoNewLine = $NoNewLine
  $script:ForegroundColor = $ForegroundColor
  $script:BackgroundColor = $BackgroundColor
  $script:Separator = $Separator
  
  if ($script:exec_write_host_actual) { Write-Host-Actual @PSBoundParameters}
}