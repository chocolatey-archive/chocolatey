function Get-WebFile {
param(
  $url,
  $fileName,
  [switch] $Passthru,
  [switch] $quiet
)
   
  $script:get_webfile_was_called = $true
  $script:url = $url
  $script:fileName = $fileName
  $script:Passthru = $Passthru
  $script:quiet = $quiet
  
  if ($script:exec_get_webfile_actual) { Get-WebFile-Actual @PSBoundParameters}
}
