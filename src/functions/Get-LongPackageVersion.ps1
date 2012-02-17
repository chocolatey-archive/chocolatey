Function Get-LongPackageVersion {
param(
 [string]$packageVersion = ''
)
  #todo - make this compare prerelease information as well
  $longVersion = $packageVersion.Split('-')[0].Split('.') | %{('0' * (8 - $_.Length)) + $_}
  return [System.String]::Join('.',$longVersion)
}