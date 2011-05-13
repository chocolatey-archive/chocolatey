namespace Chocolatey.Repositories
{
    public interface ILinqRepository<TDomainObject,TIdType> where TDomainObject : class,new()
    {
        TDomainObject FindOrCreate(TIdType id);
        void Save(TDomainObject domainObject);
    }
}