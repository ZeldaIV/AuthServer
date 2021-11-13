namespace AuthServer.Utilities
{
    public class ControllerUtils : IControllerUtils
    {
        public IStores Stores { get; }

        public ControllerUtils(
            IStores stores)
        {
            Stores = stores;
        }
    }
}