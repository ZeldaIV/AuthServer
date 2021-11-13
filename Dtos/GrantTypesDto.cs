
namespace AuthServer.Dtos
{
    public enum GrantTypesDto
    {
        NotSet = 0,
        AuthorizationCode = 1,
        ClientCredentials = 2,
        Implicit = 3,
        Password = 4,
        RefreshToken = 5,
    }
}