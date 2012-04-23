function Generate-BinFile {
param(
  [string] $name, 
  [string] $path,
  [switch] $useStart
)
  
  $script:generate_binfile_was_called = $true
  $script:name = $name
  $script:path = $path
  $script:useStart = $useStart
  
  if ($script:exec_generate_binfile_actual) { Generate-BinFile-Actual @PSBoundParameters}
}