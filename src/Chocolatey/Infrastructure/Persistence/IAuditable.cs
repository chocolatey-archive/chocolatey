namespace Chocolatey.Infrastructure.Persistence
{
    using System;

    public interface IAuditable
    {
        DateTime? EnteredDate { get; set; }
        DateTime? ModifiedDate { get; set; }
        string EnteredByUser { get; set; }
        string ModifiedByUser { get; set; }
    }
}