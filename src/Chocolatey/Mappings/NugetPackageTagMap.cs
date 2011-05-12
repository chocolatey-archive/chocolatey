namespace Chocolatey.Mappings
{
    using Domain;

    public class NugetPackageTagMap : BaseMap<NugetPackageTag>
    {
        public NugetPackageTagMap()
        {
            Map(x => x.Name);
        }
    }
}