using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using Microsoft.EntityFrameworkCore;
using OpenIddict.Abstractions;
using Serilog;

namespace AuthServer.DbServices
{
    public class ClientService : IClientService, IAsyncDisposable
    {
        private readonly IOpenIddictApplicationManager _applicationManager;
        private readonly ApplicationDbContext _context;

        public ClientService(IDbContextFactory<ApplicationDbContext> context,
            IOpenIddictApplicationManager applicationManager)
        {
            _applicationManager = applicationManager;
            _context = context.CreateDbContext();
        }

        public ValueTask DisposeAsync()
        {
            return _context.DisposeAsync();
        }

        public IEnumerable<ApplicationClient> GetAll()
        {
            return _context.ApplicationClients.ToList();
        }

        public ApplicationClient GetById(Guid id)
        {
            try
            {
                return _context.ApplicationClients.Single(c => c.Id == id);
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task CreateAsync(ApplicationClient applicationClient, CancellationToken cancellationToken)
        {
            if (applicationClient == null) throw new ArgumentNullException(nameof(applicationClient));

            var entity = await _applicationManager.FindByIdAsync(applicationClient.Id.ToString(), cancellationToken);
            if (entity == null)
                await _applicationManager.CreateAsync(applicationClient, applicationClient.ClientSecret,
                    cancellationToken);
        }

        public async Task UpdateAsync(ApplicationClient update, CancellationToken cancellationToken)
        {
            var entity = await _applicationManager.FindByIdAsync(update.Id.ToString(), cancellationToken);
            if (entity != null)
                await _applicationManager.UpdateAsync(update, update.ClientSecret ?? "", cancellationToken);
        }

        public async Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken)
        {
            var entity = await _applicationManager.FindByIdAsync(id.ToString(), cancellationToken);
            if (entity != null)
            {
                await _applicationManager.DeleteAsync(entity, cancellationToken);
                return true;
            }

            return false;
        }
    }
}