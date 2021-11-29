using AuthServer.Data.Models;
using OpenIddict.Abstractions;

namespace AuthServer.Utilities
{
    public class Stores : IStores
    {
        //
        // public Stores(IOpenIddictApplicationStore<ApplicationClient> clientStore,
        //     IOpenIddictAuthorizationStore<ApplicationAuthorization> resourceStore)
        // {
        //     ClientStore = clientStore;
        //     ResourceStore = resourceStore;
        // }

        public IOpenIddictApplicationStore<ApplicationClient> ClientStore { get; set; }
        public IOpenIddictAuthorizationStore<ApplicationAuthorization> ResourceStore { get; set; }
    }
}