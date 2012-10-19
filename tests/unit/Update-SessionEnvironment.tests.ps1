$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

$identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal( $identity )
$isAdmin = $principal.IsInRole( [System.Security.Principal.WindowsBuiltInRole]::Administrator )
if(-not $isAdmin){return}

Describe "When calling Update-SessionEnvironment anormally" {
  $originalURegPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $originalMRegPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $originalEnv = @{}
  $mkey = 'choc' + [Guid]::NewGuid().ToString('n')
  $mvalue = [Guid]::NewGuid().ToString('n')  
  $ukey = 'choc' + [Guid]::NewGuid().ToString('n')
  $uvalue = [Guid]::NewGuid().ToString('n')    
  gci env: | % {$originalEnv.($_.Name)=$_.Value}
  try {
    [Environment]::SetEnvironmentVariable($ukey, $uvalue, 'User')
    [Environment]::SetEnvironmentVariable($ukey, 'someval', 'Machine')  
    [Environment]::SetEnvironmentVariable($mkey, $mvalue, 'Machine')  
    [Environment]::SetEnvironmentVariable('Path', 'someval1', 'User')  
    [Environment]::SetEnvironmentVariable('Path', 'someval2', 'Machine')  
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
    [Environment]::SetEnvironmentVariable($mkey, $null, 'Machine')
    [Environment]::SetEnvironmentVariable($ukey, $null, 'Machine')  
    [Environment]::SetEnvironmentVariable($ukey, $null, 'User')
    [Environment]::SetEnvironmentVariable('Path', $originalMRegPath, 'Machine') 
    [Environment]::SetEnvironmentVariable('Path', $originalURegPath, 'User')
    $originalEnv.keys | % { Set-Item "Env:$($_)" -Value $originalEnv.$($_) }
  }
}