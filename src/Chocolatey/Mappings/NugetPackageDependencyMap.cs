namespace Chocolatey.Mappings
{
    using Domain;

    public class NugetPackageDependencyMap : BaseMap<NugetPackageDependency>
    {
        public NugetPackageDependencyMap()
        {
            Map(x => x.Name);
            Map(x => x.Version);
        }
    }
}