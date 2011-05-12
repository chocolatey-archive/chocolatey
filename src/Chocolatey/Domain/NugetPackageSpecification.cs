namespace Chocolatey.Domain
{
    using System.Collections.Generic;

    public class NugetPackageSpecification : BaseDomainModel
    {
        public virtual string NugetId { get; set; }
        public virtual string Name { get; set; }
        public virtual string Version { get; set; }
        public virtual IEnumerable<NugetPackageAuthor> Authors { get; set; }
        public virtual IEnumerable<NugetPackageOwner> Owners { get; set; }
        public virtual string Summary { get; set; }
        public virtual string Description { get; set; }
        public virtual string ProjectUrl { get; set; }
        public virtual IEnumerable<NugetPackageTag> Tags { get; set; }
        public virtual string LicenseUrl { get; set; }
        public virtual string IconUrl { get; set; }
        public virtual IEnumerable<NugetPackageDependency> Dependencies { get; set; }
    }
}