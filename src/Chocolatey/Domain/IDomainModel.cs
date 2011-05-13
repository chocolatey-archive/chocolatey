namespace Chocolatey.Domain
{
    public interface IDomainModel<T>
    {
        T Id { get; set; }
    }
}