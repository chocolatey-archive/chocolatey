using NUnit.Framework;
using Rhino.Mocks;
using StructureMap;
using StructureMap.AutoMocking;

namespace Chocolatey.Tests
{
    public class InteractionContext<T> where T : class
    {
        private readonly MockMode _mode;

        private RhinoAutoMocker<T> _services;

        public InteractionContext(MockMode mode)
        {
            _mode = mode;
        }

        public InteractionContext()
            : this(MockMode.AAA)
        {
        }

        public IContainer Container { get { return Services.Container; } }

        public RhinoAutoMocker<T> Services { get { return _services; } }

        public T ClassUnderTest { get { return _services.ClassUnderTest; } }

        [SetUp]
        public void SetUp()
        {
            _services = new RhinoAutoMocker<T>(_mode);

            beforeEach();
        }

        // Override this for context specific setup
        protected virtual void beforeEach()
        {
        }

        public SERVICE MockFor<SERVICE>() where SERVICE : class
        {
            return _services.Get<SERVICE>();
        }

        public void VerifyCallsFor<MOCK>() where MOCK : class
        {
            MockFor<MOCK>().VerifyAllExpectations();
        }
    }
}