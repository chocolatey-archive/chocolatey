namespace Chocolatey.Infrastructure.Persistence
{
    using NHibernate;

    public interface INHibernateUnitOfWork : IUnitOfWork
    {
        ISession CurrentSession { get; }
    }
}