namespace Chocolatey.Domain
{
    public class NugetNuspec : BaseDomainModel
    {
        public virtual string NugetId { get; set; }
        public virtual string Name { get; set; }
        public virtual string Version { get; set; }
        public virtual string Authors { get; set; }
        public virtual string Owners { get; set; }
        public virtual string Summary { get; set; }
        public virtual string Description { get; set; }
        public virtual string ProjectUrl { get; set; }
        public virtual string Tags { get; set; }
        public virtual string LicenseUrl { get; set; }
        public virtual string IconUrl { get; set; }

    }
}