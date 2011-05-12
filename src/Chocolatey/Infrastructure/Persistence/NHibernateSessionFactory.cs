namespace Chocolatey.Infrastructure.Persistence
{
    using Chocolatey.Mappings;
    using FluentNHibernate.Cfg;
    using FluentNHibernate.Cfg.Db;
    using NHibernate;
    using NHibernate.Event;

    public class NHibernateSessionFactory
    {
        public static ISessionFactory BuildSessionFactory(string database_config_name)
        {
            return Fluently.Configure()
                     .Database(MsSqlConfiguration.MsSql2005
                         .ConnectionString(c =>
                             c.FromConnectionStringWithKey(database_config_name)))
                     .Mappings(m =>
                     {
                         m.FluentMappings.AddFromAssemblyOf<NugetPackageSpecificationMap>()
                            .Conventions.AddFromAssemblyOf<NugetPackageSpecificationMap>();
                         m.HbmMappings.AddFromAssemblyOf<NugetPackageSpecificationMap>();
                     })

                     .ExposeConfiguration(cfg =>
                     {
                         cfg.SetListener(ListenerType.PreInsert, new AuditEventListener());
                         cfg.SetListener(ListenerType.PreUpdate, new AuditEventListener());
                     })
                     .BuildSessionFactory();
        }
    }
}