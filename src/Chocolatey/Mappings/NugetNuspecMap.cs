namespace Chocolatey.Mappings
{
    using Domain;

    public class NugetNuspecMap : BaseMap<NugetNuspec>
    {
        public NugetNuspecMap()
        {
            Map(x => x.NugetId);
            Map(x => x.Name);
            Map(x => x.Version);
            Map(x => x.Authors);
            Map(x => x.Owners);
            Map(x => x.Summary);
            Map(x => x.Description);
            Map(x => x.ProjectUrl);
            Map(x => x.Tags);
            Map(x => x.LicenseUrl);
            Map(x => x.IconUrl);
        }
    }
}