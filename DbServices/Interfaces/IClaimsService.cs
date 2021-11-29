using System.Security.Claims;
using AuthServer.Data.Models;

namespace AuthServer.DbServices.Interfaces
{
    public interface IClaimsService : IDbService<Claim>
    {
        
    }
}