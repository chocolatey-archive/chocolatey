namespace Chocolatey.Tests.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using Chocolatey.Repositories;
    using Domain;
    using Infrastructure.Persistence;
    using Rhino.Mocks;

    public class NugetPackageRepositorySpecs
    {
        public abstract class NugetPackageRepositorySpecsBase : TinySpec
        {
            protected IRepository repositoryMock;
            protected NugetPackageRepository repository;
            protected NugetPackage expectedPackage;
            protected string expectedNugetId = "timmy";


            public override void Context()
            {
                repositoryMock = MockRepository.GenerateStub<IRepository>();
                repository = new NugetPackageRepository(repositoryMock);
                expectedPackage = new NugetPackage();
            }

            protected IQueryable<NugetPackage> SetUpPackageList()
            {
                return new List<NugetPackage>
                           {
                               new NugetPackage{ Id=1,NugetId = expectedNugetId,Name = "timmy"},
                               new NugetPackage{ Id=2, NugetId = "nh",Name = "yep"}
                           }.AsQueryable();
            }

        }

        public class when_creating_the_NugetPackageRepository : NugetPackageRepositorySpecsBase
        {
            public override void Because()
            {
                //context did the setup here
            }

            [Fact]
            public void should_create_successfully()
            {
                //nothing to test here  
            }

            [Fact]
            public void should_not_be_null()
            {
                repository.ShouldNotBeNull();
            }
        }

        public class when_getting_a_package_NugetPackageRepository_FindOrCreate_with_an_id_that_does_Not_exist : NugetPackageRepositorySpecsBase
        {
            private NugetPackage package;

            public override void Context()
            {
                base.Context();
                
                repositoryMock.Stub(x => x.Find<NugetPackage>()).IgnoreArguments().Return(SetUpPackageList());
            }

            public override void Because()
            {
                package = repository.FindOrCreate(0);
            }

            [Fact]
            public void should_not_be_null()
            {
                package.ShouldNotBeNull();
            }

            [Fact]
            public void should_return_a_new_item()
            {
                package.Id.ShouldEqual(0);
            }

            [Fact]
            public void should_have_called_Find_on_the_repository_mock()
            {
                repositoryMock.AssertWasCalled(x => x.Find<NugetPackage>());
            }

            [Fact]
            public void should_return_an_item_that_does_not_have_NugetId_filled_out()
            {
                package.NugetId.ShouldBeNull();
            }
        }
    
        public class when_getting_a_package_NugetPackageRepository_FindOrCreate_with_an_id_that_exists : NugetPackageRepositorySpecsBase
        {
            private NugetPackage package;

            public override void Context()
            {
                base.Context();
                
                repositoryMock.Stub(x => x.Find<NugetPackage>()).IgnoreArguments().Return(SetUpPackageList());
            }

            public override void Because()
            {
                package = repository.FindOrCreate(1);
            }

            [Fact]
            public void should_not_be_null()
            {
                package.ShouldNotBeNull();
            }

            [Fact]
            public void should_return_an_existing_item()
            {
                package.Id.ShouldEqual(1);
            }

            [Fact]
            public void should_have_called_Find_on_the_repository_mock()
            {
                repositoryMock.AssertWasCalled(x => x.Find<NugetPackage>());
            }

            [Fact]
            public void should_have_the_same_nugetId_as_the_matched_item()
            {
                package.NugetId.ShouldEqual(expectedNugetId);
            }
        }


    }
}