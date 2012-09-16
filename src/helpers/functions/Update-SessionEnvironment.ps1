function Update-SessionEnvironment {

  $user = 'HKCU:\Environment'
  $machine ='HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
  #ordering is important here, $user comes after so we can override $machine
  $machine, $user |
    Get-Item |
    % {
      $regPath = $_.PSPath
      $_ |
        Select -ExpandProperty Property |
        % {
          Set-Item "Env:$($_)" -Value (Get-ItemProperty $regPath -Name $_).$_
        }
    }

  #Path gets special treatment b/c it munges the two together
  $paths = 'Machine', 'User' |
    % {
      [Environment]::GetEnvironmentVariable('PATH', $_) -split ';'
    } |
    Select -Unique
  $Env:PATH = $paths -join ';'
}
