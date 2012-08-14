function Chocolatey-Sources {
param(
  [string] $operation='', 
  [string] $name='' , 
  [string] $source='' 
)

    switch($operation)
    {
        "list" {												
                Get-Sources | format-table @{Expression={$_.id};Label="ID";width=25},@{Expression={$_.value};Label="URI"}
            }
            
        "add" {
				Write-UserConfig { param($userConfig)
				
	                $newSource = $userConfig.selectSingleNode("//source[@id='$name']")
	                if (-not $newSource){
	                    
	                    $newSource = $userConfig.CreateElement("source")
	                    
	                    $idAttr = $userConfig.CreateAttribute("id")
	                    $idAttr.Value = $name
	                    $newSource.SetAttributeNode($idAttr) | Out-Null
	                    
	                    $valueAttr = $userConfig.CreateAttribute("value")
	                    $valueAttr.Value = $source
	                    $newSource.SetAttributeNode($valueAttr) | Out-Null
	                    
	                	$sources = $userConfig.selectSingleNode("//sources")
	                    $sources.AppendChild($newSource) | Out-Null
	                    
	                    Write-Host "Source $name added."
						$true
	                }
	                else {
	                    Write-Host "Source $name already exists"
	                }
				}                
            }
            
        "remove" {
				Write-UserConfig { param($userConfig)
                
	                $source = $userConfig.selectSingleNode("//source[@id='$name']")
	                if ($source){                    
	                    
	                	$sources = $userConfig.selectSingleNode("//sources")
	                    $sources.RemoveChild($source) | Out-Null
	                    
	                    Write-Host "Source $name removed."
						$true
	                }
	                else {
	                    Write-Host "Source $name does not exist or is a global which can't be removed (use disable if this is the case)."
	                }
				}
            }
			
		"enable" {
				Write-UserConfig { param($userConfig)
	                
	                $disabledNode = $userConfig.selectSingleNode("//disabled[@id='$name']")
	                if ($disabledNode){                    
	                    
	                	$sources = $userConfig.selectSingleNode("//sources")
	                    $sources.RemoveChild($disabledNode) | Out-Null
	                    
	                    Write-Host "Source $name enabled."
						$true
	                }
	                else {
	                    Write-Host "Source $name already enabled"
	                }
				}
            }
		
		"disable" {
				Write-UserConfig { param($userConfig)
				
	                $disabledNode = $userConfig.selectSingleNode("//disabled[@id='$name']")
	                if (-not $disabledNode){
	                    
	                    $disabledNode = $userConfig.CreateElement("disabled")
	                    
	                    $idAttr = $userConfig.CreateAttribute("id")
	                    $idAttr.Value = $name
	                    $disabledNode.SetAttributeNode($idAttr) | Out-Null
	                    
	                	$sources = $userConfig.selectSingleNode("//sources")
	                    $sources.AppendChild($disabledNode) | Out-Null
	                    
	                    Write-Host "Source $name disabled."
						$true
	                }
	                else {
	                    Write-Host "Source $name already disabled"
	                }
				}
            }
            
        default { Write-Host "Unrecognized sources operation '$operation'"}
    }
}

