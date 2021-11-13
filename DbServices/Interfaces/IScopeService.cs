using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.Dtos;

namespace AuthServer.DbServices.Interfaces
{
    public interface IScopeService
    {
        List<ApplicationScope> GetScopes();
        Task AddScope(ApplicationScope scope, CancellationToken cancellationToken);
        ApplicationScope GetScopeById(Guid id);
        Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken);
    }
}