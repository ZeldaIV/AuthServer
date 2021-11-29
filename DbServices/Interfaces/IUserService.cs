using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;

namespace AuthServer.DbServices.Interfaces
{
    public interface IUserService: IDbService<UserDto>
    {
        Task<bool> AddUserClaims(Guid userId, List<Guid> claimIds);
        Task<bool> RemoveClaimFromUser(Guid userId, Guid claimId, CancellationToken cancellationToken);
        Task<List<Claim>> GetUserClaims(Guid id, CancellationToken cancellationToken);
    }
}