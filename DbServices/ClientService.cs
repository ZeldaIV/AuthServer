using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using Microsoft.EntityFrameworkCore;
using NuGet.Protocol;
using OpenIddict.Abstractions;
using OpenIddict.Core;
using OpenIddict.EntityFrameworkCore.Models;
using Serilog;

namespace AuthServer.DbServices
{
    public class ClientService : IClientService, IAsyncDisposable, IDisposable
    {
        private readonly OpenIddictApplicationManager<ApplicationClient> _applicationManager;
        private readonly ApplicationDbContext _context;

        public ClientService(IDbContextFactory<ApplicationDbContext> context,
            OpenIddictApplicationManager<ApplicationClient> applicationManager)
        {
            _applicationManager = applicationManager;
            _context = context.CreateDbContext();
        }

        public ValueTask DisposeAsync()
        {
            if (_context is IAsyncDisposable ad)
            {
                return ad.DisposeAsync();
            }
            _context.Dispose();
            return ValueTask.CompletedTask;
        }

        public IEnumerable<ApplicationClient> GetAll()
        {
            var applicationClients = _context.ApplicationClients.ToList();
            return applicationClients;
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
            var entity = await _applicationManager.FindByIdAsync(update.ClientId ?? update.Id.ToString(), cancellationToken);
            if (entity != null)
            {
                UpdateProperties(update, entity);
                await _applicationManager.UpdateAsync(entity, update.ClientSecret ?? "", cancellationToken);
            }
                
        }
        private static void UpdateProperties(
            ApplicationClient model,
            ApplicationClient entity
        )
        {
            entity.ConsentType = model.ConsentType; 
            entity.Permissions = model.Permissions; 
            entity.RedirectUris =  model.RedirectUris;
            entity.PostLogoutRedirectUris = model.PostLogoutRedirectUris; 
            entity.Requirements =  model.Requirements;
        }

        public async Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken)
        {
            var entity = await _applicationManager.FindByIdAsync(id.ToString(), cancellationToken);
            if (entity == null) 
                return false;
            await _applicationManager.DeleteAsync(entity, cancellationToken);
            return true;

        }

        public void Dispose()
        {
            _context?.Dispose();
        }
    }
}