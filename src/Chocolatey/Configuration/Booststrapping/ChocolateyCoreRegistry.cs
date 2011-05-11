using StructureMap.Configuration.DSL;

namespace Chocolatey.Configuration.Booststrapping
{
    public class ChocolateyCoreRegistry : Registry
    {
        public ChocolateyCoreRegistry()
        {
            Scan(x =>
                     {
                         x.TheCallingAssembly();
                         x.LookForRegistries();
                     });
        }
    }
}