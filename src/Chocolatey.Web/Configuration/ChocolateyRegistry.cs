using FubuMVC.Core;

namespace Chocolatey.Web.Configuration
{
    public class ChocolateyRegistry : FubuRegistry
    {
        public ChocolateyRegistry()
        {
            IncludeDiagnostics(true);

            Applies
                .ToThisAssembly();
        }
    }
}