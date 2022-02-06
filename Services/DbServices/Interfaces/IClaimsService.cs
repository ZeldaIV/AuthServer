using AuthServer.Data.Models;

namespace AuthServer.Services.DbServices.Interfaces
{
    public interface IClaimsService : IDbService<ApplicationClaimType>
    {
    }
}