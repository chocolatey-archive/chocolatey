namespace Chocolatey.Infrastructure.Persistence.Conventions
{
    using System;
    using FluentNHibernate.Conventions;
    using FluentNHibernate.Conventions.AcceptanceCriteria;
    using FluentNHibernate.Conventions.Inspections;
    using FluentNHibernate.Conventions.Instances;

    //[CLSCompliant(false)]
    public class StringVarCharConvention : IPropertyConvention, IPropertyConventionAcceptance
    {
        public void Apply(IPropertyInstance instance)
        {
            int length = 255;
            var instanceProperties = instance as IPropertyInspector;
            if (instanceProperties != null)
            {
                var existingLength = instanceProperties.Length;
                length = existingLength == 0 ? length : existingLength;
            }

            instance.CustomSqlType("VarChar(" + length + ")");
        }

        public void Accept(IAcceptanceCriteria<IPropertyInspector> criteria)
        {
            criteria
                .Expect(x => x.Type == typeof(string))
                .Expect(x => x.SqlType, Is.Not.Set);
        }
    }
}