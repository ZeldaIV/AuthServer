using System.Collections.Generic;
using System.Linq;
using AuthServer.Data;
using IdentityServer4.EntityFramework.Entities;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ApiResourceController
    {
        private readonly IIdentityServerDbContext _context;

        public ApiResourceController(IIdentityServerDbContext context)
        {
            _context = context;
        }
        
        [HttpGet]
        public List<ApiResource> GetApiResources()
        {
            return _context.GetAllApiResources().ToList();
        }

        [HttpPost]
        public void AddResource(ApiResource resource)
        {
            
        }
    }
}