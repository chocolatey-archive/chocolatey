namespace Chocolatey.Web.Actions.Package
{
    using System.Collections.Generic;
    using Domain;
    using FubuMVC.Core.View;
    using Infrastructure.Persistence;

    public class ListAction
    {
        private readonly IRepository _repository;

        public ListAction(IRepository repository)
        {
            _repository = repository;
        }


        public PackageListOutput Get(PackageListInput input)
        {
            var list = _repository.GetAll<NugetPackageSpecification>();

            return new PackageListOutput
                       {
                           Packages = list
                       };
        }
    }

    public class PackageListInput {}

    public class PackageListOutput
    {
        public IEnumerable<NugetPackageSpecification> Packages { get; set; }
    }

    public class List : FubuPage<PackageListOutput>
    {
        
    }
}