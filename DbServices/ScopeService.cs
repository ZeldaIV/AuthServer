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
using Serilog;

namespace AuthServer.DbServices
{
    public sealed class ScopeService : IScopeService, IAsyncDisposable
    {
        private readonly ApplicationDbContext _context;

        public ScopeService(IDbContextFactory<ApplicationDbContext> context)
        {
            _context = context.CreateDbContext();
        }

        public ValueTask DisposeAsync()
        {
            return _context.DisposeAsync();
        }

        public List<ApplicationScope> GetScopes()
        {
            return _context.ApplicationScopes.Adapt<List<ApplicationScope>>().ToList();
        }

        public async Task AddScope(ApplicationScope scope, CancellationToken cancellationToken)
        {
            var newScope = scope;
            try
            {
                await _context.ApplicationScopes.AddAsync(newScope, cancellationToken);
                await _context.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public ApplicationScope GetScopeById(Guid id)
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
            try
            {
                var result = await _context.ApplicationScopes.SingleAsync(r => r.Id == id, cancellationToken);
                _context.ApplicationScopes.Remove(result);
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