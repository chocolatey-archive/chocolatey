namespace Chocolatey.Web.Actions.Home
{
    using FubuMVC.Core.View;

    public class HomeAction
    {
        public HomeAction()
        {
        }

        public HomeResponse Get(HomeRequest request)
        {
            return new HomeResponse();
        }
    }

    public class HomeRequest { }

    public class HomeResponse
    {
        public static string Name = "Chocolatey";
    }
    
    public class Home : FubuPage<HomeResponse>
    {
        
    }
}