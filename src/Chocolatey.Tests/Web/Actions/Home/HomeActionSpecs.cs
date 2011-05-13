namespace Chocolatey.Tests.Web.Actions.Home
{
    using Chocolatey.Web.Actions.Home;

    public class HomeActionSpecs
    {
        public abstract class HomeActionSpecsBase : TinySpec
        {
            protected HomeAction action;

            public override void Context()
            {
                action = new HomeAction();
            }
        }

        public class when_requesting_homeaction_with_null_request : HomeActionSpecsBase
        {
            protected HomeResponse response;

            public override void Because()
            {
                response = action.Get(null);
            }

            [Fact]
            public void should_return_a_valid_response()
            {
                response.ShouldNotBeNull();
            }

            [Fact]
            public void should_return_the_name_of_the_application_based_on_the_application_parameters_value()
            {
                HomeResponse.Name.ShouldBeTheSameAs(AppParameters.ApplicationName);
            }

        }

        public class when_requesting_homeaction_with_new_request : HomeActionSpecsBase
        {
            protected HomeResponse response;

            public override void Because()
            {
                response = action.Get(new HomeRequest());
            }

            [Fact]
            public void should_return_a_valid_response()
            {
                response.ShouldNotBeNull();
            }
        }
    }
}