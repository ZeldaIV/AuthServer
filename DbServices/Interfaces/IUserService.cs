using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;
using Microsoft.AspNetCore.Identity;

namespace AuthServer.DbServices.Interfaces
{
    public interface IUserService
    {
        Task AddUser(UserDto user, CancellationToken cancellationToken);
        List<UserDto> GetUsers();
        UserDto GetUserById(string id);
        Task<bool> DeleteByIdAsync(string id, CancellationToken cancellationToken);
    }
}