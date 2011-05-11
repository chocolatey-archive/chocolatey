namespace Chocolatey.Mappings
{
    using System;
    using Domain;
    using FluentNHibernate.Mapping;

    // [CLSCompliant(false)]
    public class BaseMap<TDomainModel> : ClassMap<TDomainModel>
        where TDomainModel : BaseDomainModel
    {
        public BaseMap()
        {
            Schema("dbo");
            Id(x => x.Id).GeneratedBy.Identity().Access.CamelCaseField(Prefix.Underscore).UnsavedValue(0);

            Map(x => x.EnteredDate);
            Map(x => x.ModifiedDate);
            Map(x => x.EnteredByUser);
            Map(x => x.ModifiedByUser);
        }
    }
}