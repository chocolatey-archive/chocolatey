namespace Chocolatey.Web.Configuration
{
    using Actions.Package.Edit;
    using AutoMapper;
    using Domain;

    public class ChocolateyAutoMapperWebProfile : Profile
    {
        protected override void Configure()
        {
            RecognizePrefixes(new[] {"NugetPackage"});

            CreateDomainMap<PackageEditSubmit, NugetPackage>()
                .ForMember(dest => dest.Authors, opt => opt.Ignore())
                .ForMember(dest => dest.Owners, opt => opt.Ignore())
                .ForMember(dest => dest.Tags, opt => opt.Ignore())
                .ForMember(dest => dest.Dependencies, opt => opt.Ignore());
           
        }

        public IMappingExpression<TInput, TOutput> CreateDomainMap<TInput, TOutput>() where TOutput : BaseDomainModel
        {
            return CreateMap<TInput, TOutput>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.EnteredDate, opt => opt.Ignore())
                .ForMember(dest => dest.EnteredByUser, opt => opt.Ignore())
                .ForMember(dest => dest.ModifiedDate, opt => opt.Ignore())
                .ForMember(dest => dest.ModifiedByUser, opt => opt.Ignore());

        }

        public override string ProfileName
        {
            get { return AppParameters.ApplicationNameWeb; }
        }
    }
}