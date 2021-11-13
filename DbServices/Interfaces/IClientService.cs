using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.Dtos;

namespace AuthServer.DbServices.Interfaces
{
    public interface IClientService
    {
        List<ApplicationClient> GetAllClients();
        ApplicationClient GetClientById(Guid id);
        Task AddClientAsync(ApplicationClient applicationClient, CancellationToken cancellationToken);
        Task UpdateClient(ApplicationClient update, CancellationToken cancellationToken);
        Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken);
    }
}