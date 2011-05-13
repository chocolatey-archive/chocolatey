using System;
using System.Web.Routing;
using Chocolatey.Web.Configuration;
using Chocolatey.Web.Configuration.Bootstrapping;
using FubuMVC.Core;
using FubuMVC.StructureMap;

namespace Chocolatey.Web
{
    using AutoMapper;

    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            FubuApplication
                .For<ChocolateyRegistry>()
                .StructureMapObjectFactory(x => x.AddRegistry<ChocolateyWebCoreRegistry>())
                .Bootstrap(RouteTable.Routes);

            Mapper.AddProfile(new ChocolateyAutoMapperWebProfile());
        }
    }
}