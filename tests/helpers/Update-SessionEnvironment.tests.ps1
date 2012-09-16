$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$helpers = Join-Path (Split-Path (Split-Path $here)) 'src\helpers\functions'
$helper = Join-Path $helpers 'Update-SessionEnvironment.ps1'
. $helper

Describe "When calling Update-SessionEnvironment normally" {
  function TestRandomVariable
  {
    param (
      [Parameter(Mandatory = $true)]
      [ValidateSet('User', 'Machine')]
      $target
    )

    $key = 'choc' + [Guid]::NewGuid().ToString('n')
    $value = [Guid]::NewGuid().ToString('n')

    try
    {
      [Environment]::SetEnvironmentVariable($key, $value, $target)

      #ensure current session unaffected
      (Test-Path "Env:$($key)").should.be($false)

      Update-SessionEnvironment

      #new variable has appeared
      $localSession = Get-ChildItem "Env:$($key)"
      $localSession.Value.should.be($value)
    }
    finally
    {
      #remove our junk environment variable
      Remove-Item "Env:$($key)" -ErrorAction SilentlyContinue
      [Environment]::SetEnvironmentVariable($key, $null, $target)
    }
  }

  function TestPathUpdate
  {
    param (
      [Parameter(Mandatory = $true)]
      [ValidateSet('User', 'Machine')]
      $target
    )

    $key = 'PATH'
    $value = ';' + [Guid]::NewGuid().ToString('n')

    $originalEnvPath = $Env:PATH
    $originalRegPath = [Environment]::GetEnvironmentVariable($key, $target)

    try
    {
      [Environment]::SetEnvironmentVariable($key,
        ($originalRegPath + $value), $target)

      #ensure current session unaffected
      $testPath = $Env:PATH
      if ($testPath -imatch $value)
      {
        throw New-Object PesterFailure("$testPath should not contain $value",
          "$testPath was like $value")
      }

      Update-SessionEnvironment

      #new variable has appeared
      $testPath = $Env:PATH
      if ($Env:PATH -inotmatch $value)
      {
        throw New-Object PesterFailure("PATH variable not set",
          "$testPath should contain $value")
      }
    }
    finally
    {
      #remove our junk environment variable
      $Env:PATH = $originalEnvPath
      [Environment]::SetEnvironmentVariable($key, $originalRegPath, $target)
    }
  }

  It "should properly refresh MACHINE variables set outside this session" {
    #NOTE: admin access is required to make this call
    TestRandomVariable 'Machine'
  }

  It "should properly refresh USER variables set outside this session" {
    TestRandomVariable 'User'
  }

  It "should properly refresh the PATH variable as updated in MACHINE" {
    TestPathUpdate 'Machine'
  }

  It "should properly refresh the PATH variable as updated in USER" {
    TestPathUpdate 'User'
  }
}
