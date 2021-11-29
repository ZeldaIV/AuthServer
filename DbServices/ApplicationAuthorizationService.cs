using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Serilog;

namespace AuthServer.DbServices
{
    public class ApplicationAuthorizationService : IApplicationAuthorizationService, IAsyncDisposable
    {
        private readonly ApplicationDbContext _context;

        public ApplicationAuthorizationService(IDbContextFactory<ApplicationDbContext> context)
        {
            _context = context.CreateDbContext();
        }

        public IEnumerable<ApplicationAuthorization> GetAll()
        {
            return _context.ApplicationAuthorizations.Adapt<List<ApplicationAuthorization>>();
        }

        public ApplicationAuthorization GetById(Guid id)
        {
            try
            {
                return _context.ApplicationAuthorizations.Single(r => r.Id == id);
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task CreateAsync(ApplicationAuthorization resource, CancellationToken cancellationToken)
        {
            var newResource = resource;
            newResource.CreationDate = DateTime.UtcNow;

            try
            {
                await _context.ApplicationAuthorizations.AddAsync(newResource, cancellationToken);
                await _context.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task UpdateAsync(ApplicationAuthorization update, CancellationToken cancellationToken)
        {
            var resource = update;
            var entity =
                await _context.ApplicationAuthorizations.FirstOrDefaultAsync(r => r.Id == update.Id, cancellationToken);
            if (entity != null)
            {
                entity.Id = resource.Id;
                entity.Application = resource.Application;
                entity.Scopes = resource.Scopes;
                entity.Status = resource.Status;
                entity.Subject = resource.Subject;
                entity.CreationDate = resource.CreationDate;
                entity.Type = resource.Type;
            }

            try
            {
                await _context.SaveChangesAsync(cancellationToken);
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
                var result = await _context.ApplicationAuthorizations.SingleAsync(r => r.Id == id, cancellationToken);
                _context.ApplicationAuthorizations.Remove(result);
                return true;
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                return false;
            }
        }

        public ValueTask DisposeAsync()
        {
            return _context.DisposeAsync();
        }
    }
}