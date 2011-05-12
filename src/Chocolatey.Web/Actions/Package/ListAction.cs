namespace Chocolatey.Web.Actions.Package
{
    using FubuMVC.Core.View;

    public class ListAction
    {
        public PackageListOutput Get(PackageListInput input)
        {
            return new PackageListOutput();
        }
    }

    public class PackageListInput {}
    public class PackageListOutput {}

    public class List : FubuPage<PackageListOutput>
    {
        
    }
}