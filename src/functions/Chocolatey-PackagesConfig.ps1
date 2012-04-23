function Chocolatey-PackagesConfig {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $packagesConfigPath
)

  if(-not(Test-Path $packagesConfigPath)) {
    if (-not($($packagesConfigPath).Contains('\'))) {
      Chocolatey-NuGet $packagesConfigPath
    }
    
    return
  }
  
  $h1
  "Installing packages from manifest: '$(Resolve-Path $packagesConfigPath)'"
  $h1
  
  $xml = [xml] (Get-Content $packagesConfigPath)
  $xml.packages.package | ?{ $_.id -ne '' -and $_.id -ne $null} | %{
    Chocolatey-Install -packageName $_.id -source $_.source -version $_.version
  }
}