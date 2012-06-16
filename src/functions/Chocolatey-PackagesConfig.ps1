function Chocolatey-PackagesConfig {
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $packagesConfigPath
)
  Write-Debug "Running 'Chocolatey-PackagesConfig' with packagesConfigPath:`'$packagesConfigPath`'";

  if(-not(Test-Path $packagesConfigPath)) {
    Write-Debug "No file exists at `'$packagesConfigPath`'"
    if (-not($($packagesConfigPath).Contains('\'))) {
      Write-Debug "Going to attempt to install $packagesConfigPath as regular chocolatey package."
      Chocolatey-NuGet $packagesConfigPath
    }
    
    return
  }
  
  $h1
  "Installing packages from manifest: '$(Resolve-Path $packagesConfigPath)'"
  $h1
  
  $xml = [xml] (Get-Content $packagesConfigPath)
  $xml.packages.package | ?{ $_.id -ne '' -and $_.id -ne $null} | %{
    Write-Debug "Calling Chocolatey-Install -packageName $_.id -source $_.source -version $_.version"
    Chocolatey-Install -packageName $_.id -source $_.source -version $_.version
  }
}