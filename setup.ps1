### install chocolatey ###
iex ((new-object net.webclient).DownloadString("http://bit.ly/psChocInstall"))

# install nuget if it is missing
cinstm nuget.commandline
cinstm pester