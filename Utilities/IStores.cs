using IdentityServer4.Stores;

namespace AuthServer.Utilities
{
    public interface IStores
    {
        public IClientStore ClientStore { get; set; }
        public IResourceStore ResourceStore { get; set; }
    }
}