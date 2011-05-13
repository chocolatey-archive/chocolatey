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


        public PackageListResponse Get(PackageListRequest request)
        {
            var list = _repository.GetAll<NugetPackage>();

            return new PackageListResponse
                       {
                           Packages = list
                       };
        }
    }

    public class PackageListRequest {}

    public class PackageListResponse
    {
        public IEnumerable<NugetPackage> Packages { get; set; }
    }

    public class List : FubuPage<PackageListResponse>
    {
        
    }
}