function Get-LongPackageVersion {
param(
  [string] $packageVersion = ''
)
  #todo - make this compare prerelease information as well
  $longVersion = $packageVersion.Split('-')[0].Split('.') | %{('0' * (8 - $_.Length)) + $_}
  
  $longVersionReturn = [System.String]::Join('.',$longVersion)
  
  if ($packageVersion.Contains('-')) {
    $prerelease = $packageVersion.Substring($packageVersion.IndexOf('-') + 1)
    $longVersionReturn += ".$($prerelease)"
  }
  
  return $longVersionReturn
}