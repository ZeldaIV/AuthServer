using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using IdentityServer4.EntityFramework.DbContexts;
using IdentityServer4.EntityFramework.Entities;
using IdentityServer4.EntityFramework.Interfaces;

namespace AuthServer.Data
{
    public interface IIdentityServerDbContext
    {
        public IEnumerable<ApiResource> GetAllApiResources();
        public Task AddApiResourceAsync(ApiResource resource, CancellationToken cancellationToken);
    }
    
    public sealed class IdentityServerDbContext : IIdentityServerDbContext
    {
        private readonly ConfigurationDbContext _context;

        public IdentityServerDbContext(ConfigurationDbContext context)
        {
            _context = context;
        }

        public IEnumerable<ApiResource> GetAllApiResources()
        {
            return _context.ApiResources;
        }

        public async Task AddApiResourceAsync(ApiResource resource, CancellationToken cancellationToken)
        {
            await _context.ApiResources.AddAsync(resource, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}