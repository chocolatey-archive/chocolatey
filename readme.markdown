Chocolatey NuGet
=======
![Chocolatey Logo](https://github.com/ferventcoder/chocolatey/raw/master/docs/logo/chocolateyicon.gif "Chocolatey")  
  
# LICENSE
Apache 2.0 - see docs/legal (just LEGAL in the zip folder)
  
# IMPORTANT
NOTE: If you are looking at the source - please run build.bat before opening the solution. It creates the SolutionVersion.cs file that is necessary for a successful build.  
  
# INFO
## Overview
Chocolatey is like apt-get, but for Windows.  
  
## Getting started with Chocolatey  
### Downloads
  
You can obtain chocolatey from http://nuget.org/list/packages/chocolatey  
  
`Install-Package chocolatey`  
`Initialize-Chocolatey`  
`Uninstall-Package chocolatey`  
  
### Source
This is the best way to get to the bleeding edge of the code.  
  
1. Clone the source down to your machine.  
  `git clone git://github.com/ferventcoder/chocolatey.git`  
2. Type `cd chocolaty`  
3. Type `git config core.autocrlf false` to set line endings to auto convert for this repository  
4. Type `git status`. You should not see any files to change.  
5. Run `build.bat`. NOTE: You must have git on the path (open a regular command line and type git).  
  
# REQUIREMENTS  
* .NET Framework 4.0  
* Source control on the command line and in PATH environment variable - git for Git  
  
# DONATE  
  
  The best donation you can give is to talk about chocolatey and use it if you like it. If you really enjoy it, contribute packages or ideas  
  
# RELEASE NOTES  
=0.9.8=  
* Lots of good stuff.  
  
  
# CREDITS  
see docs/legal/CREDITS (just LEGAL/Credits in the zip folder)  