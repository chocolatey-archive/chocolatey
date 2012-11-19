$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Update-SessionEnvironment.ps1"

Add-Type -language CSharp @'
public class FakeRegKey
{
    public string PSPath;
    public string[] Property;

    public FakeRegKey(string PSPath,string[] Property){
        this.PSPath = PSPath;
        this.Property = Property;
    } 
}
'@

Describe "When calling Update-SessionEnvironment anormally" {
  $originalEnv = @{}
  $mkey = 'choc' + [Guid]::NewGuid().ToString('n')
  $mvalue = [Guid]::NewGuid().ToString('n')  
  $ukey = 'choc' + [Guid]::NewGuid().ToString('n')
  $uvalue = [Guid]::NewGuid().ToString('n')    
  gci env: | % {$originalEnv.($_.Name)=$_.Value}
  try {
    #Mock Get-Item {write-host "path: $path"}
    Mock Get-Item {
      if($_ -eq 'HKCU:\Environment'){
        return New-Object FakeRegKey("user",@($ukey,"Path"))
      } 
      if($_ -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'){
        return New-Object FakeRegKey("machine",@($ukey,$mkey,"Path"))
      }
    }
    #Mock Get-Item {New-Object FakeRegKey("path2",@($ukey,$mkey,"Path"))} -ParameterFilter {$path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'}
    Mock Get-ItemProperty {@{$ukey="someval"}} -ParameterFilter {$path -eq "machine" -and $Name -eq $ukey}
    Mock Get-ItemProperty {@{Path="someval1"}} -ParameterFilter {$path -eq "user" -and $Name -eq "Path"}
    Mock Get-ItemProperty {@{Path="someval2"}} -ParameterFilter {$path -eq "machine" -and $Name -eq "Path"}
    Mock Get-ItemProperty {@{$ukey=$uvalue}} -ParameterFilter {$path -eq "user" -and $Name -eq $ukey}
    Mock Get-ItemProperty {@{$mkey=$mvalue}} -ParameterFilter {$path -eq "machine" -and $Name -eq $mkey}
    Mock Get-EnvironmentVar {"someval2"} -ParameterFilter {$key -eq "PATH" -and $scope -eq "Machine"}
    Mock Get-EnvironmentVar {"someval1"} -ParameterFilter {$key -eq "PATH" -and $scope -eq "User"}
    Remove-Item "Env:$($ukey)" -ErrorAction SilentlyContinue
    Remove-Item "Env:$($mkey)" -ErrorAction SilentlyContinue
    Remove-Item "Env:$('Path')" -ErrorAction SilentlyContinue

    Update-SessionEnvironment

    $mlocalSession = Get-ChildItem "Env:$($mkey)"
    $ulocalSession = Get-ChildItem "Env:$($ukey)"
    $plocalSession = Get-ChildItem "Env:$('Path')"

    It "should properly refresh MACHINE variables set outside this session" {
        $mlocalSession.Value.should.be($mvalue)
    }
    It "should properly refresh USER variables set outside this session overriding Machine vars with same key" {
        $ulocalSession.Value.should.be($uvalue)
    }
    It "should properly refresh the PATH variable aconcatenating MACHINE and USER" {
      $plocalSession.Value.should.be('someval2;someval1')
    }
  }
  finally {
    $originalEnv.keys | % { Set-Item "Env:$($_)" -Value $originalEnv.$($_) }
  }
}