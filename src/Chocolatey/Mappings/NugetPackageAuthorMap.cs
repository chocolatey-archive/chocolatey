namespace Chocolatey.Mappings
{
    using Domain;

    public class NugetPackageAuthorMap : BaseMap<NugetPackageAuthor>
    {
        public NugetPackageAuthorMap()
        {
            Map(x => x.Name);
        }
    }
}