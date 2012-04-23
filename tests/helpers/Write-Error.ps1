#not overwriting this one
function Write-Error-Local {
param(
  [string] $Message,
  [System.Management.Automation.ErrorCategory] $Category,
  [string] $ErrorId,
  [object] $TargetObject,
  [string] $CategoryActivity,
  [string] $CategoryReason,
  [string] $CategoryTargetName,
  [string] $CategoryTargetType,
  [string] $RecommendedAction
)

  $script:write_error_was_called = $true
  $script:Message = $Message
  $script:Category = $Category
  $script:ErrorId = $ErrorId
  $script:TargetObject = $TargetObject
  $script:CategoryActivity = $CategoryActivity
  $script:CategoryReason = $CategoryReason
  $script:CategoryTargetName = $CategoryTargetName
  $script:CategoryTargetType = $CategoryTargetType
  $script:RecommendedAction = $RecommendedAction
  
  if ($script:exec_write_error_actual) { Write-Error-Actual @PSBoundParameters}
}