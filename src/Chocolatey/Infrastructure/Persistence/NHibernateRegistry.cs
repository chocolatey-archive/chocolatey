namespace Chocolatey.Infrastructure.Persistence
{
    using FluentNHibernate;
    using FluentNHibernate.Cfg;
    using StructureMap.Configuration.DSL;

    public class NHibernateRegistry :
        Registry
    {
        public NHibernateRegistry()
        {
            For<IRepository>().Use<NHibernateRepository>();

            For<IUnitOfWork>().Use(ctx => ctx.GetInstance<INHibernateUnitOfWork>());

            For<INHibernateUnitOfWork>().HybridHttpOrThreadLocalScoped().Use<NHibernateUnitOfWork>();

            For<ISessionSource>().Singleton().Use(ctx => new SessionSource(NHibernateConfiguration.GetConfiguration("chocolatey")));


        }
    }
}