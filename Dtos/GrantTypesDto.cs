using IdentityServer4.Models;

namespace AuthServer.Dtos
{
    public enum GrantTypesDto
    {
        NotSet = 0,
        Implicit = 1,
        ImplicitAndClientCredentials = 2,
        Code = 3,
        CodeAndClientCredentials = 4,
        Hybrid = 5,
        HybridAndClientCredentials = 6,
        ClientCredentials = 7,
        ResourceOwnerPassword = 8,
        ResourceOwnerPasswordAndClientCredentials = 9,
        DeviceFlow = 10,
    }
}