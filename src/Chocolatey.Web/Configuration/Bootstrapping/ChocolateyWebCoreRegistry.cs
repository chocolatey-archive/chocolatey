using Chocolatey.Configuration.Booststrapping;
using StructureMap.Configuration.DSL;

namespace Chocolatey.Web.Configuration.Bootstrapping
{
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
        }
    }
}