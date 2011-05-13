namespace Chocolatey.Infrastructure.Persistence
{
    using System.Collections.Generic;
    using System.Linq;
    using NHibernate.Criterion;

    public interface IRepository
    {
        T Get<T>(int id);
        IQueryable<T> Find<T>();
        IList<T> Find<T>(DetachedCriteria dc);
        void Add<T>(T entity);
        void Delete<T>(T item);
    }
}