function Chocolatey-Help {
@"
Version: `'$chocVer'`
Install Directory: `'$nugetPath`'

== Chocolatey? ==
"I'm a tools enabler, a global silent installer. I met your mother.
 Some want to call me apt-get for Windows, I just want to get #chocolatey!"

Chocolatey is a package manager for Windows (like apt-get but for Windows).
 It was designed to be a decentralized framework for quickly installing
 applications and tools that you need. It is built on the NuGet
 infrastructure currently using PowerShell as its focus for delivering
 packages from the distros to your door, err computer.

Chocolatey is brought to you by the work and inspiration of the community,
 the work and thankless nights of the Chocolatey Team
 (https://github.com/orgs/chocolatey/members), and Rob (@ferventcoder)
 heading up the direction.

You can host your own sources and add them to chocolatey, you can extend
 chocolatey's capabilities, and folks, it's only going to get better.

== Chocolatey gods? ==
Humor related to playing off of tiki gods. We like humor. Don't take life
 so seriously, you will never get out alive.

== Release Notes ==
https://github.com/chocolatey/chocolatey/wiki/ReleaseNotes

== Package License Acceptance Terms ==
The act of running chocolatey to install a package constitutes acceptance
 of the license for the application, executable(s), or other artifacts
 that are brought to your machine as a result of a chocolatey install.
This acceptance occurs whether you know the license terms or not. It is
 suggested that you read and understand the license terms of any package
 you plan to install prior to installation through chocolatey.
If you do not accept the license of a package you are installing, please
 uninstall it and any artifacts that end up on your machine as a result
 of the install.

== Waiver of Responsibility ==
The use of chocolatey means that an individual using chocolatey assumes
 the responsibility for any changes (including any damages of any sort)
 that occur to the system as a result of using chocolatey.
This does not supercede the verbage or enforcement of the license for
 chocolatey (currently Apache 2.0), it is only noted here that you are
 waiving any rights to collect damages by your use of chocolatey.
It is recommended you read the license
 (http://www.apache.org/licenses/LICENSE-2.0) to gain a full understanding
 (especially section 8. Limitation of Liability) prior to using chocolatey.

== Commands ==
For all commands check out the command reference at:
 https://github.com/chocolatey/chocolatey/wiki/CommandsReference

 * Search - choco search something
 * List locally installed packages - choco list -lo
 * Install - choco install baretail
 * Update - choco update baretail
 * Uninstall - choco uninstall baretail
 * Install ruby gem - choco install compass -source ruby
 * Install python egg - choco install sphynx -source python
 * Install windows feature - choco install IIS -source windowsfeatures
 * Install webpi feature - choco install IIS7.5Express -source webpi

More advanced commands and switches listed on the command reference,
 including how you can force a package to install the x86 version of a
 package.

 Examples:
  * choco install nunit
  * choco install nunit -version 2.5.7.10213
  * choco install packages.config
  * choco update nunit -source http://somelocalfeed.com/nuget/
  * choco help
  * choco search nunit
  * choco list -localonly
  * choco version
  * choco version nunit
  * choco uninstall nunit
  * choco install sphynx -source python

== Create Packages? ==
We have some great guidance on how to do that. Where? I'll give you a
 hint, it rhymes with sticky!
 https://github.com/chocolatey/chocolatey/wiki/CreatePackages

In that mess there is a link to the Helper Reference -
 https://github.com/chocolatey/chocolatey/wiki/HelpersReference
"@ | Write-Host
}
