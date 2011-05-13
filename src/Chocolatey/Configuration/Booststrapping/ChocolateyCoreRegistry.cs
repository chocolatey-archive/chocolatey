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

            For<IRepository>().Singleton().Use(ctx => new NHibernateRepository(NHibernateSessionFactory.BuildSessionFactory("chocolatey")));
            For<ILinqRepository<NugetPackage, long>>().Add<NugetPackageRepository>();
        }
    }
}