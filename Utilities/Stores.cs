using IdentityServer4.Stores;

namespace AuthServer.Utilities
{
    public class Stores: IStores
    {
        public IClientStore ClientStore { get; set; }
        public IResourceStore ResourceStore { get; set; }
        
        public Stores(IClientStore clientStore, IResourceStore resourceStore)
        {
            ClientStore = clientStore;
            ResourceStore = resourceStore;
        }
    }
}