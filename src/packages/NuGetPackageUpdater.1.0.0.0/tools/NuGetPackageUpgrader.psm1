#Based on https://gist.github.com/747529
###########################################################
#
# Script to upgrade all NuGet packages in solution to last version
#
# USAGE
# ========================
#NuGet Package Updater
#========================
#This applies a global update of packages to your solution. 
#Every project that is using a package is upgraded to the latest.
#Please run 'Update-Package' OR 'Update-Package all' to upgrade all packages to current version. 
#Please run 'Update-Package packageName' to upgrade just one package. 
#========================
#
# Do not hestitate to contact me at any time
# mike@chaliy.name, http://twitter.com/chaliy
#
# Update to NuGet 1.1 is done by JasonGrundy, see comments bellow
# 
#
##########################################################

function Update-Package {
param($packageName ='all')

  if ($packageName -like 'all') {
    $packages = get-package -update
  } else {
    $packages = get-package $packageName
  }

  $upNormal=Get-Command 'Update-Package' -CommandType Cmdlet;

  foreach ($package in $packages) {
    write-host "Updating $($package.Id) in all referenced projects"
    $PackageID = $package.Id
    $packageManager = $host.PrivateData.packageManagerFactory.CreatePackageManager()

    foreach ($project in Get-Project -all) {
      $fileSystem = New-Object NuGet.PhysicalFileSystem($project.Properties.Item("FullPath").Value) 	
      $repo = New-Object NuGet.PackageReferenceRepository($fileSystem, $packageManager.LocalRepository)

      foreach ($package in $repo.GetPackages() | ? {$_.Id -eq $PackageID}) {
        & $upNormal $package.Id -Project:$project.Name
      }
    }
  }
}

export-modulemember -function Update-Package;