using AuthServer.Data.Models;
using OpenIddict.Abstractions;

namespace AuthServer.Utilities
{
    public interface IStores
    {
        public IOpenIddictApplicationStore<ApplicationClient> ClientStore { get; set; }
        public IOpenIddictAuthorizationStore<ApplicationAuthorization> ResourceStore { get; set; }
    }
}