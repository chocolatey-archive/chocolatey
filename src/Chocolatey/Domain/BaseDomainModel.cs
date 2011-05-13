namespace Chocolatey.Domain
{
    using System;
    using Infrastructure.Persistence;

    public class BaseDomainModel : IDomainModel<long>, IAuditable
    {
        private long _id;

        public virtual long Id
        {
            get { return _id; }
            set { _id = value; }
        }

        public virtual DateTime? EnteredDate { get; set; }
        public virtual DateTime? ModifiedDate { get; set; }
        public virtual string EnteredByUser { get; set; }
        public virtual string ModifiedByUser { get; set; }
    }
}