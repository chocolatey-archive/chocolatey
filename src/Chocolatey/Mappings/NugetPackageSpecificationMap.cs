namespace Chocolatey.Mappings
{
    using Domain;

    public class NugetPackageSpecificationMap : BaseMap<NugetPackage>
    {
        public NugetPackageSpecificationMap()
        {
            Map(x => x.NugetId);
            Map(x => x.Name);
            Map(x => x.Version);
            HasMany(x => x.Authors).Cascade.AllDeleteOrphan();
            HasMany(x => x.Owners).Cascade.AllDeleteOrphan(); 
            Map(x => x.Summary);
            Map(x => x.Description);
            Map(x => x.ProjectUrl);
            Map(x => x.LicenseUrl);
            Map(x => x.IconUrl);
            
            HasMany(x => x.Tags).Cascade.AllDeleteOrphan();
            HasMany(x => x.Dependencies).Cascade.AllDeleteOrphan();

        }
    }
}