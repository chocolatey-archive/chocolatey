using StructureMap.Configuration.DSL;

namespace Chocolatey.Configuration.Booststrapping
{
    using Domain;
    using Infrastructure.Persistence;
    using Repositories;

    public class ChocolateyCoreRegistry : Registry
    {
        public ChocolateyCoreRegistry()
        {
            Scan(x =>
                     {
                         x.TheCallingAssembly();
                         x.LookForRegistries();
                      });

            IncludeRegistry<NHibernateRegistry>();

            For<ILinqRepository<NugetPackage, long>>().Add<NugetPackageRepository>();
        }
    }
}