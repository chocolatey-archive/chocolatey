namespace Chocolatey.Domain
{
    public class NugetPackageDependency :BaseDomainModel
    {
        public virtual string Name { get; set; }
        public virtual string Version { get; set; }
    }
}