namespace Chocolatey.Web.Actions.Home
{
    using FubuMVC.Core.View;

    public class HomeAction
    {
        public HomeAction()
        {
        }

        public HomeOutput Get(HomeInput input)
        {
            return new HomeOutput();
        }
    }

    public class HomeInput { }

    public class HomeOutput
    {
        public static string Name = "Chocolatey";
    }
    
    public class Home : FubuPage<HomeOutput>
    {
        
    }
}