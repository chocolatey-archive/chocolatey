namespace Chocolatey.Infrastructure.Persistence
{
    using System;
    using System.Security.Principal;
    using System.Web;
    using NHibernate.Event;
    using NHibernate.Persister.Entity;

    public class AuditEventListener : IPreInsertEventListener, IPreUpdateEventListener
    {
        public string GetIdentityName()
        {
            string userIdentity = WindowsIdentity.GetCurrent().Name;

            if (HttpContext.Current != null)
            {
                try
                {
                    userIdentity = HttpContext.Current.User.Identity.Name;
                }
                catch
                {
                    //move on
                }
            }

            return userIdentity;
        }

        //http://ayende.com/Blog/archive/2009/04/29/nhibernate-ipreupdateeventlistener-amp-ipreinserteventlistener.aspx
        public bool OnPreInsert(PreInsertEvent event_item)
        {
            var audit = event_item.Entity as IAuditable;
            if (audit == null)
            {
                return false;
            }

            DateTime? enteredDate = DateTime.Now;
            string userIdentity = GetIdentityName();

            store(event_item.Persister, event_item.State, "EnteredDate", enteredDate);
            store(event_item.Persister, event_item.State, "ModifiedDate", enteredDate);
            store(event_item.Persister, event_item.State, "EnteredByUser", userIdentity);
            store(event_item.Persister, event_item.State, "ModifiedByUser", userIdentity);
            audit.EnteredDate = enteredDate;
            audit.ModifiedDate = enteredDate;
            audit.EnteredByUser = userIdentity;
            audit.ModifiedByUser = userIdentity;

            return false;
        }

        public bool OnPreUpdate(PreUpdateEvent event_item)
        {
            var audit = event_item.Entity as IAuditable;
            if (audit == null)
            {
                return false;
            }

            DateTime? modifiedDate = DateTime.Now; 
            string userIdentity = GetIdentityName();

            store(event_item.Persister, event_item.State, "ModifiedDate", modifiedDate);
            store(event_item.Persister, event_item.State, "ModifiedByUser", userIdentity);
            audit.ModifiedDate = modifiedDate;
            audit.ModifiedByUser = userIdentity;

            return false;
        }

        public void store(IEntityPersister persister, object[] state, string property_name, object value)
        {
            int index = Array.IndexOf(persister.PropertyNames, property_name);
            if (index == -1)
            {
                return;
            }
            state[index] = value;
        }
    }
}