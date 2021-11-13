using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using Mapster;
using Microsoft.EntityFrameworkCore;
using OpenIddict.Abstractions;
using Serilog;

namespace AuthServer.DbServices
{
    public class ClientService : IClientService, IAsyncDisposable
    {
        private readonly ApplicationDbContext _context;

        public ClientService(IDbContextFactory<ApplicationDbContext> context)
        {
            _context = context.CreateDbContext();
        }

        public ValueTask DisposeAsync()
        {
            return _context.DisposeAsync();
        }

        public List<ApplicationClient> GetAllClients()
        {
            return _context.ApplicationClients.ToList();
        }

        public ApplicationClient GetClientById(Guid id)
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

        public async Task AddClientAsync(ApplicationClient applicationClient, CancellationToken cancellationToken)
        {
            var entity = applicationClient;
            try
            {
                await _context.ApplicationClients.AddAsync(entity, cancellationToken);
                await _context.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task UpdateClient(ApplicationClient update, CancellationToken cancellationToken)
        {
            try
            {
                var entity = await _context.ApplicationClients.FirstOrDefaultAsync(c => c.Id == update.Id, cancellationToken);
                if (entity != null)
                {
                    entity.ClientId = update.ClientId;
                    entity.ClientSecret = update.ClientSecret;
                    entity.ConsentType = update.ConsentType;
                    entity.DisplayName = update.DisplayName;
                    entity.DisplayNames = update.DisplayNames;
                    entity.Permissions = update.Permissions;
                    entity.PostLogoutRedirectUris = update.PostLogoutRedirectUris;
                    entity.RedirectUris = update.RedirectUris;
                    entity.Type = update.Type;
                }

                await _context.SaveChangesAsync(cancellationToken);
            }
            catch (ArgumentNullException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
            catch (DbUpdateException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken)
        {
            try
            {
                var result = await _context.ApplicationClients.SingleAsync(r => r.Id == id, cancellationToken);
                _context.ApplicationClients.Remove(result);
                return true;
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                return false;
            }
        }
    }
}