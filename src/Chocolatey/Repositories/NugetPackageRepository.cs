namespace Chocolatey.Repositories
{
    using System;
    using Domain;
    using Infrastructure.Persistence;
    using System.Linq;

    //todo: will this become a generic?
    public class NugetPackageRepository : ILinqRepository<NugetPackage,long>
    {
        private readonly IRepository _repository;

        public NugetPackageRepository(IRepository repository)
        {
            _repository = repository;
        }

        public NugetPackage FindOrCreate(long id)
        {
            return _repository.Find<NugetPackage>()
                .Where(p => p.Id == id)
                .DefaultIfEmpty(new NugetPackage())
                .FirstOrDefault();
        }

        public void Save(NugetPackage domainObject)
        {
            _repository.SaveOrUpdate(domainObject);
        }
    }
}