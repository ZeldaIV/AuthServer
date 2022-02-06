using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.Services.DbServices.Interfaces;
using Mapster;
using Microsoft.EntityFrameworkCore;
using OpenIddict.Abstractions;
using Serilog;

namespace AuthServer.Services.DbServices
{
    public sealed class ScopeService : IScopeService, IAsyncDisposable, IDisposable
    {
        private readonly ApplicationDbContext _context;
        private readonly IOpenIddictScopeManager _scopeManager;

        public ScopeService(IDbContextFactory<ApplicationDbContext> context, IOpenIddictScopeManager scopeManager)
        {
            _scopeManager = scopeManager;
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

        public IEnumerable<ApplicationScope> GetAll()
        {
            return _context.ApplicationScopes.Adapt<List<ApplicationScope>>().ToList();
        }

        public async Task CreateAsync(ApplicationScope scope, CancellationToken cancellationToken)
        {
            if (scope == null) throw new ArgumentNullException(nameof(scope));

            var entity = await _scopeManager.FindByIdAsync(scope.Id.ToString(), cancellationToken);
            if (entity == null) await _scopeManager.CreateAsync(scope, cancellationToken);
        }

        public async Task UpdateAsync(ApplicationScope update, CancellationToken cancellationToken)
        {
            var entity = await _scopeManager.FindByIdAsync(update.Id.ToString(), cancellationToken);
            if (entity != null)
            {
                await _scopeManager.UpdateAsync(entity, cancellationToken);
            }
        }

        public ApplicationScope GetById(Guid id)
        {
            try
            {
                return _context.ApplicationScopes.Single(s => s.Id == id);
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken)
        {
            var entity = await _scopeManager.FindByIdAsync(id.ToString(), cancellationToken);
            if (entity == null)
                return false;

            await _scopeManager.DeleteAsync(entity, cancellationToken);
            return true;
        }

        public void Dispose()
        {
            _context?.Dispose();
        }
    }
}