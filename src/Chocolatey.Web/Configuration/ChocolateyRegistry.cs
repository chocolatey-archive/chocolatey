using FubuMVC.Core;

namespace Chocolatey.Web.Configuration
{
    using Actions.Home;

    public class ChocolateyRegistry : FubuRegistry
    {
        public ChocolateyRegistry()
        {
            IncludeDiagnostics(true);

            Applies.ToThisAssembly();

            Actions.IncludeTypesNamed(x => x.EndsWith("Action"));
            
            Routes
                .IgnoreNamespaceText("Chocolatey.Web.Actions")
                .IgnoreControllerNamesEntirely()
                .IgnoreClassSuffix("Action")
                .IgnoreMethodsNamed("Execute")
                .IgnoreMethodsNamed("Get").ConstrainToHttpMethod(action => action.Method.Name.Equals("Get"), "GET")
                .IgnoreMethodsNamed("Post").ConstrainToHttpMethod(action => action.Method.Name.Equals("Post"), "POST")
                //.IgnoreMethodsNamed("Delete").ConstrainToHttpMethod(action => action.Method.Name.Equals("Delete"), "DELETE")
                //.IgnoreMethodsNamed("Put").ConstrainToHttpMethod(action => action.Method.Name.Equals("Put"), "PUT")
                ;

            Routes.HomeIs<HomeAction>(x => x.Get(null));

            Views.TryToAttachWithDefaultConventions();
        }
    }
}