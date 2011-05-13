namespace Chocolatey.Tests.Web.Configuration
{
    using System;
    using AutoMapper;
    using Chocolatey.Web.Configuration;

    public class ChocolateyAutoMapperWebProfileSpecs
    {
        public abstract class ChocolateyAutoMapperWebProfileSpecsBase : TinySpec {}

        public class when_setting_up_the_ChocolateyAutoMapperWebProfile : ChocolateyAutoMapperWebProfileSpecsBase
        {
            public override void Context() {}

            public override void Because()
            {
                Mapper.AddProfile(new ChocolateyAutoMapperWebProfile());
            }

            [Fact]
            public void the_profile_should_add_successfully()
            {
               //no errors in the add profile
            }

            [Fact]
            public void should_address_the_import_successfully()
            {
                Mapper.AssertConfigurationIsValid();
            }
        }
    }
}