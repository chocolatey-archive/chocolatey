namespace Chocolatey.FileTemplates
{
    public class NuspecTemplate
    {
        public static string template =
@"<?xml version=""1.0""?>
<package xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <metadata>
    <id>{NugetId}</id>
    <title>{Name}</title>
    <version>{Version}</version>
    <authors>{Authors}</authors>
    <owners>{Owners}</owners>
    <summary>{Summary}</summary>
    <description>{Description}
| Please install with chocolatey (http://nuget.org/List/Packages/chocolatey).</description>
    <projectUrl>{ProjectUrl}</projectUrl>
    <tags>{Tags} chocolatey</tags>
    <licenseUrl>{LicenseUrl}</licenseUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <iconUrl>{IconUrl}</iconUrl>

    <dependencies>
      <dependency id=""chocolatey"" version=""0.9.8"" />
    </dependencies>
  </metadata>
</package>

";
    }
}