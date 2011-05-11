namespace Chocolatey.Infrastructure.Persistence
{
    using System.Collections.Generic;
    using NHibernate;
    using NHibernate.Criterion;

    public interface IRepository
    {
        IList<T> GetAll<T>();
        IList<T> GetWithCriteria<T>(DetachedCriteria detachedCriteria);
        void SaveOrUpdate<T>(IList<T> list);
        void SaveOrUpdate<T>(T item);
        void Delete<T>(IList<T> list);

        ISessionFactory SessionFactory { get; }
        //string connection_string { get; }
    }
}