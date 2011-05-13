namespace Chocolatey.Infrastructure.Persistence
{
    using System.Collections.Generic;
    using System.Linq;
    using NHibernate;
    using NHibernate.Criterion;

    public interface IRepository
    {
        IQueryable<T> Find<T>() where T : class;
        IList<T> GetAll<T>();
        IList<T> GetWithCriteria<T>(DetachedCriteria detachedCriteria);
        void SaveOrUpdate<T>(IList<T> list);
        void SaveOrUpdate<T>(T item);
        void Delete<T>(IList<T> list);

        ISessionFactory SessionFactory { get; }
        //string connection_string { get; }
    }
}