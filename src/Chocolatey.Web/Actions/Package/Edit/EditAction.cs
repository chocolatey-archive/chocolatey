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

        public string NugetPackageNugetId { get; set; }
        public string NugetPackageName { get; set; }
        public string NugetPackageVersion { get; set; }
        //public IEnumerable<NugetPackageAuthor> Authors { get; set; }
        //public IEnumerable<NugetPackageOwner> Owners { get; set; }
        public string NugetPackageSummary { get; set; }
        public string NugetPackageDescription { get; set; }
        public string NugetPackageProjectUrl { get; set; }
        //public IEnumerable<NugetPackageTag> Tags { get; set; }
        public string NugetPackageLicenseUrl { get; set; }
        public string NugetPackageIconUrl { get; set; }
        //public IEnumerable<NugetPackageDependency> Dependencies { get; set; }
    }

    public class Edit : FubuPage<PackageEditResponse> { }

}