using AuthServer.Data.Models;

namespace AuthServer.DbServices.Interfaces
{
    public interface IApplicationAuthorizationService : IDbService<ApplicationAuthorization>
    {
    }
}