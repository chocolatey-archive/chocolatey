using Chocolatey.Configuration.Booststrapping;
using StructureMap.Configuration.DSL;

namespace Chocolatey.Web.Configuration.Bootstrapping
{
    using AutoMapper;

    public class ChocolateyWebCoreRegistry : Registry
    {
        public ChocolateyWebCoreRegistry()
        {
            Scan(x =>
                     {
                         x.TheCallingAssembly();
                         x.LookForRegistries();
                     });

            IncludeRegistry<ChocolateyCoreRegistry>();

            Mapper.AddProfile(new ChocolateyAutoMapperWebProfile());
            For<IMappingEngine>().Singleton().Use(Mapper.Engine);
        }
    }
}