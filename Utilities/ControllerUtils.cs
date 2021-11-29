namespace AuthServer.Utilities
{
    public class ControllerUtils : IControllerUtils
    {
        public ControllerUtils(
            IStores stores)
        {
            Stores = stores;
        }

        public IStores Stores { get; }
    }
}