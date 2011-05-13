namespace Chocolatey.Infrastructure.Persistence
{
    public interface IUnitOfWork
    {
        void Initialize();
        void Commit();
        void Rollback();
        void Dispose();
    }
}