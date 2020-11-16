using System.Collections.Generic;

using IdentityServer4.EntityFramework.Entities;
using IdentityServer4.EntityFramework.Interfaces;

namespace AuthServer.Data
{
    public interface IIdentityServerDbContext
    {
        public IEnumerable<ApiResource> GetAllApiResources();
    }
    
    public sealed class IdentityServerDbContext : IIdentityServerDbContext
    {
        private readonly IConfigurationDbContext _context;

        public IdentityServerDbContext(IConfigurationDbContext context)
        {
            _context = context;
        }

        public IEnumerable<ApiResource> GetAllApiResources()
        {
            return _context.ApiResources;
        }
    }
}