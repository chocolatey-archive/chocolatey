namespace BuildOrUpdateDatabase
{
    using System;
    using System.Reflection;
    using FluentNHibernate.Cfg;
    using FluentNHibernate.Cfg.Db;
    using log4net;
    using NHibernate;
    using NHibernate.Cfg;

    public class NHibernateSessionFactory
    {
        private static readonly ILog logger = LogManager.GetLogger(typeof(NHibernateSessionFactory));

        public static ISessionFactory build_session_factory<TYPE,CONVENTIONS_TYPE>(string db_server, string db_name, Action<Configuration> additional_function)
        {
            logger.Debug("Building Session Factory");
            return Fluently.Configure()
                .Database(MsSqlConfiguration.MsSql2005
                              .ConnectionString(c => c.Server(db_server).Database(db_name).TrustedConnection())
                )
                .Mappings(m =>
                {
                    m.FluentMappings.AddFromAssemblyOf<TYPE>()
                        .Conventions.AddFromAssemblyOf<CONVENTIONS_TYPE>();
                })
                .ExposeConfiguration(additional_function)
                .BuildSessionFactory();

        }

        #region new stuff

       public static ISessionFactory build_session_factory(string db_server, string db_name, Assembly fluent_mapping_assembly, Assembly fluent_convention_assembly, Action<Configuration> additional_function)
        {
            logger.Debug("Building Session Factory");
            return Fluently.Configure()
                .Database(MsSqlConfiguration.MsSql2005
                              .ConnectionString(c => c.Server(db_server).Database(db_name).TrustedConnection())
                )
                .Mappings(m =>
                              {
                                  register_maps_and_conventions(m, fluent_mapping_assembly, fluent_convention_assembly);
                              })
                .ExposeConfiguration(additional_function)
                .BuildSessionFactory();

        }

        private static FluentMappingsContainer register_maps_and_conventions(MappingConfiguration mapping_configuration, Assembly fluent_mapping_assembly, Assembly fluent_convention_assembly)
        {
            FluentMappingsContainer fluent_mappings = mapping_configuration.FluentMappings;
            fluent_mappings.AddFromAssembly(fluent_mapping_assembly);
            if (fluent_convention_assembly != null)
            {
                fluent_mappings.Conventions.AddAssembly(fluent_convention_assembly);
            }

            return fluent_mappings;
        }
        #endregion

        private static void no_operation(Configuration cfg)
        {
        }
    }
}