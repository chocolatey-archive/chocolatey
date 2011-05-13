namespace Chocolatey.Infrastructure.HttpModules
{
    using System;
    using System.Web;
    using Persistence;
    using StructureMap;

    public class UnitOfWorkHttpModule : IHttpModule
    {
        private IUnitOfWork _unitOfWork;


        public void Init(HttpApplication context)
        {
            context.BeginRequest += NewRequest;
            context.EndRequest += EndRequest;
        }


        private void NewRequest(object sender, EventArgs e)
        {
            _unitOfWork = ObjectFactory.GetInstance<IUnitOfWork>();
            _unitOfWork.Initialize();
        }

        private void EndRequest(object sender, EventArgs e)
        {
            _unitOfWork.Commit();
            _unitOfWork.Dispose();
        }

        public void Dispose()
        {
            //nothing to see here
        }
    }
}
