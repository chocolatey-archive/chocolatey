using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Chocolatey.Web.Actions.Package.Edit
{
    using AutoMapper;
    using Domain;
    using FubuMVC.Core;
    using FubuMVC.Core.Continuations;
    using FubuMVC.Core.View;
    using Repositories;

    public class EditAction
    {
        private readonly ILinqRepository<NugetPackage,long> _repository;
        private readonly IMappingEngine _mappingEngine;

        public EditAction(ILinqRepository<NugetPackage,long> repository, IMappingEngine mappingEngine)
        {
            _repository = repository;
            _mappingEngine = mappingEngine;
        }

        public PackageEditResponse Get(PackageEditRequest request)
        {
            return new PackageEditResponse
                           {
                               Package = _repository.FindOrCreate(request.Id)
                           };
        }

        public FubuContinuation Post(PackageEditSubmit submit)
        {
            var package = _repository.FindOrCreate(submit.Id);

            if (package.Id != 0)
            {
                _mappingEngine.Map(submit, package);
                _repository.Save(package);
            }

            return FubuContinuation.RedirectTo(new PackageListRequest());
        }
    }
    

    public class PackageEditRequest
    {
        [RouteInput]
        public long Id { get; set; }
    }

    public class PackageEditResponse
    {
        public NugetPackage Package { get; set; }
    }

    public class PackageEditSubmit
    {
        [RouteInput]
        public long Id { get; set; }

        public string PackageNugetId { get; set; }
        public string PackageName { get; set; }
        public string PackageVersion { get; set; }
        //public IEnumerable<NugetPackageAuthor> Authors { get; set; }
        //public IEnumerable<NugetPackageOwner> Owners { get; set; }
        public string PackageSummary { get; set; }
        public string PackageDescription { get; set; }
        public string PackageProjectUrl { get; set; }
        //public IEnumerable<NugetPackageTag> Tags { get; set; }
        public string PackageLicenseUrl { get; set; }
        public string PackageIconUrl { get; set; }
        //public IEnumerable<NugetPackageDependency> Dependencies { get; set; }
    }

    public class Edit : FubuPage<PackageEditResponse> { }

}