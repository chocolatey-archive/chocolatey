namespace Chocolatey.Infrastructure.Persistence
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using NHibernate;
    using NHibernate.Criterion;
    using NHibernate.Linq;

    public sealed class NHibernateRepository : IRepository
    {
        readonly INHibernateUnitOfWork _unit;

        public NHibernateRepository(INHibernateUnitOfWork unit)
        {
            _unit = unit;
        }

        public IList<T> Find<T>(DetachedCriteria dc)
        {
            ISession sess = _unit.CurrentSession;

            return dc.GetExecutableCriteria(sess).List<T>();
        }

        public IQueryable<T> Find<T>()
        {
            ISession sess = _unit.CurrentSession;
            return sess.Linq<T>();
        }

        public T Get<T>(int id)
        {
            return _unit.CurrentSession.Get<T>(id);
        }

        public void Add<T>(T entity)
        {
            _unit.CurrentSession.SaveOrUpdate(entity);
        }

        public void Delete<T>(T item)
        {
            _unit.CurrentSession.Delete(item);
        }

    }
}