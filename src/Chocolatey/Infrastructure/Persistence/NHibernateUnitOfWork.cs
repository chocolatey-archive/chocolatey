namespace Chocolatey.Infrastructure.Persistence
{
    using System;
    using FluentNHibernate;
    using NHibernate;

    public class NHibernateUnitOfWork : INHibernateUnitOfWork
    {
        private ITransaction _transaction;
        private bool _isDisposed;
        private readonly ISessionSource _source;
        private bool _isInitialized;

        [CLSCompliant(false)]
        public NHibernateUnitOfWork(ISessionSource source)
        {
            _source = source;
        }

        public void Initialize()
        {
            ShouldNotCurrentlyBeDisposed();

            CurrentSession = _source.CreateSession();
            BeginNewTransaction();

            _isInitialized = true;
        }

        public ISession CurrentSession { get; private set; }

        public void Commit()
        {
            ShouldNotCurrentlyBeDisposed();
            ShouldBeInitializedFirst();

            _transaction.Commit();

            BeginNewTransaction();
        }

        private void BeginNewTransaction()
        {
            if (_transaction != null)
            {
                _transaction.Dispose();
            }

            _transaction = CurrentSession.BeginTransaction();
        }

        public void Rollback()
        {
            ShouldNotCurrentlyBeDisposed();
            ShouldBeInitializedFirst();

            _transaction.Rollback();

            BeginNewTransaction();
        }

        private void ShouldNotCurrentlyBeDisposed()
        {
            if (_isDisposed) throw new ObjectDisposedException(GetType().Name);
        }

        private void ShouldBeInitializedFirst()
        {
            if (!_isInitialized)
                throw new InvalidOperationException("Must initialize (call Initialize()) on NHibernateUnitOfWork before commiting or rolling back");
        }

        public void Dispose()
        {
            if (_isDisposed || !_isInitialized) return;

            _transaction.Dispose();
            CurrentSession.Dispose();

            _isDisposed = true;
        }
    }
}