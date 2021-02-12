using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using IdentityServer4.EntityFramework.DbContexts;
using IdentityServer4.EntityFramework.Entities;

namespace AuthServer.Data
{
    public interface IIdentityServerDbContext
    {
        public IEnumerable<ApiResource> GetAllApiResources();
        public Task AddApiResourceAsync(ApiResource resource, CancellationToken cancellationToken);
        public Task UpdateApiResourceAsync(ApiResource update, CancellationToken cancellationToken);
        public IEnumerable<Client> GetAllClients();
        Task AddClient(Client client, CancellationToken cancellationToken);
        Task UpdateClient(Client update, CancellationToken cancellationToken);
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

        public async Task UpdateApiResourceAsync(ApiResource update, CancellationToken cancellationToken)
        {
            var entity = await _context.ApiResources.FindAsync(update.Id);
            if (entity != null)
            {
                entity.Name = update.Name;
                entity.Description = update.Description;
                entity.Enabled = update.Enabled;
                entity.Scopes = update.Scopes;
                entity.Secrets = update.Secrets;
                entity.DisplayName = update.DisplayName;
            }
            
            await _context.SaveChangesAsync(cancellationToken);
        }

        public IEnumerable<Client> GetAllClients()
        {
            return _context.Clients;
        }

        public async Task AddClient(Client client, CancellationToken cancellationToken)
        {
            await _context.Clients.AddAsync(client, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
        }

        public async Task UpdateClient(Client update, CancellationToken cancellationToken)
        {
            var entity = await _context.Clients.FindAsync(update.Id);
            if (entity != null)
            {
                entity.ClientId = update.ClientId;
                entity.Enabled = update.Enabled;
                entity.ClientName = update.ClientName;
                entity.Description = update.Description;
                entity.ClientUri = update.ClientUri;
                entity.LogoUri = update.LogoUri;
                entity.ClientSecrets = update.ClientSecrets;
                entity.AllowedGrantTypes = update.AllowedGrantTypes;
                entity.RedirectUris = update.RedirectUris;
                entity.AllowedScopes = update.AllowedScopes;
                entity.PostLogoutRedirectUris = update.PostLogoutRedirectUris;
                entity.Created = update.Created;
                entity.Updated = update.Updated;
                entity.LastAccessed = update.LastAccessed;
            }
            
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}