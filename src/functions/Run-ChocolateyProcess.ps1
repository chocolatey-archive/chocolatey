function Run-ChocolateyProcess {
param(
  [string] $file, 
  [string] $arguments = $args, 
  [switch] $elevated
)
	
	Write-Host "Running $file $arguments. This may take awhile and permissions may need to be elevated, depending on the package.";
  $psi = new-object System.Diagnostics.ProcessStartInfo $file;
  $psi.Arguments = $arguments;
	#$psi.Verb = "runas";
	#	$psi.CreateNoWindow = $true
	#	$psi.RedirectStandardOutput = $true;
	#	$psi.RedirectStandardError = $true;
	#	$psi.UseShellExecute = $false;
  $psi.WorkingDirectory = get-location;
 
  $s = [System.Diagnostics.Process]::Start($psi);
  $s.WaitForExit();
  if ($s.ExitCode -ne 0) {
    Write-Host "[ERROR] Running $file with $arguments was not successful." -ForegroundColor White -BackgroundColor DarkRed
  }
}