namespace Chocolatey.Mappings
{
    using Domain;

    public class NugetPackageOwnerMap : BaseMap<NugetPackageOwner>
    {
        public NugetPackageOwnerMap()
        {
            Map(x => x.Name);
        }
    }
}