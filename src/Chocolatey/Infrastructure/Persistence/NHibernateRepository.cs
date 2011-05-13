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
        public NHibernateRepository(ISessionFactory sessionFactory)
        {
            this.SessionFactory = sessionFactory;
            if (sessionFactory == null)
            {
                throw new ApplicationException("Repository cannot do any with a null session factory. Please provide a session factory.");
            }
        }

        public IQueryable<T> Find<T>() where T: class
        {
            return NHibernateExtensions.Linq<T>(SessionFactory.OpenSession());
        }

        public IList<T> GetAll<T>()
        {
            IList<T> list;
            Type persistentClass = typeof(T);

            using (ISession session = SessionFactory.OpenSession())
            {
                ICriteria criteria = session.CreateCriteria(persistentClass);
                list = criteria.List<T>();
                session.Close();
            }

           // Log.bound_to(this).log_an_info_event_containing("Repository found {0} records of type {1}.", list.Count, typeof(T).Name);

            return list;
        }

        public IList<T> GetWithCriteria<T>(DetachedCriteria detachedCriteria)
        {
            if (detachedCriteria == null)
            {
                //Log.bound_to(this).log_a_warning_event_containing(
                //    "Please ensure you send in a criteria when you want to limit records. Otherwise please consider using GetAll(). Returning empty list.");
                return null;
            }

            IList<T> list;
            using (ISession session = SessionFactory.OpenSession())
            {
                ICriteria criteria = detachedCriteria.GetExecutableCriteria(session);
                list = criteria.List<T>();
                session.Close();
            }

            //Log.bound_to(this).log_an_info_event_containing("Repository found {0} records of type {1} with criteria {2}.", list.Count, typeof(T).Name, detachedCriteria.ToString());

            return list;
        }

        public void SaveOrUpdate<T>(IList<T> list)
        {
            if (list == null || list.Count == 0)
            {
                //Log.bound_to(this).log_a_warning_event_containing(
                //    "Please ensure you send a non null list of records to save.");
                return;
            }
            //Log.bound_to(this).log_an_info_event_containing("Received {0} records of type {1} marked for save/update.", list.Count, typeof(T).Name);
            using (ISession session = SessionFactory.OpenSession())
            {
                using (ITransaction transaction = session.BeginTransaction())
                {
                    foreach (T item in list)
                    {
                        session.SaveOrUpdate(item);
                        //session.Flush();
                    }
                    transaction.Commit();
                }
                session.Close();
            }

            //Log.bound_to(this).log_an_info_event_containing("Saved {0} records of type {1} successfully.", list.Count, typeof(T).Name);
        }

        public void SaveOrUpdate<T>(T item)
        {
            if (item == null)
            {
                //Log.bound_to(this).log_a_warning_event_containing(
                //    "Please ensure you send a non null record to save.");
                return;
            }

            using (ISession session = SessionFactory.OpenSession())
            {
                using (ITransaction transaction = session.BeginTransaction())
                {
                    session.SaveOrUpdate(item);
                    //session.Flush();
                    transaction.Commit();
                }
                session.Close();
            }

            //Log.bound_to(this).log_an_info_event_containing("Saved item of type {0} successfully.", typeof(T).Name);
        }

        public void Delete<T>(IList<T> list)
        {
            if (list == null || list.Count == 0)
            {
                //Log.bound_to(this).log_a_warning_event_containing(
                //    "Please ensure you send a non null list of records to delete.");
                return;
            }

            //Log.bound_to(this).log_an_info_event_containing("Received {0} records of type {1} marked for deletion.", list.Count, typeof(T).Name);
            using (ISession session = SessionFactory.OpenSession())
            {
                using (ITransaction transaction = session.BeginTransaction())
                {
                    foreach (T item in list)
                    {
                        session.Delete(item);
                        //session.Flush();
                    }
                    transaction.Commit();
                }
                session.Close();
            }

            //Log.bound_to(this).log_an_info_event_containing("Removed {0} records of type {1} successfully.", list.Count, typeof(T).Name);
        }

        public ISessionFactory SessionFactory { get; private set; }

    }
}