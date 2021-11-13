using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.Dtos;

namespace AuthServer.DbServices.Interfaces
{
    public interface IApplicationAuthorizationService
    {
        IEnumerable<ApplicationAuthorization> GetAllAuthorizations();
        ApplicationAuthorization GetAuthorizationById(Guid id);
        Task AddAuthorizationAsync(ApplicationAuthorization resource, CancellationToken cancellationToken);
        Task UpdateAuthorizationAsync(ApplicationAuthorization update, CancellationToken cancellationToken);

        Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken);
    }
}