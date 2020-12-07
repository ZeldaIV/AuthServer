using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;
using AuthServer.Utilities;
using IdentityServer4.EntityFramework.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    
    public class ApiResourceController : ControllerBase
    {
        
        public ApiResourceController(IControllerUtils utils) : base(utils)
        {
        }
        
        [HttpGet]
        [Authorize(Policy = "Administrator")]
        public List<ApiResourceDto> GetApiResources()
        {
            var apiResources = DbContext.GetAllApiResources().ToList();
            
            return Mapper.Map<List<ApiResourceDto>>(apiResources);
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public async Task AddResource([FromBody] ApiResourceDto resource, CancellationToken cancellationToken)
        {
            var newResource = Mapper.Map<ApiResource>(resource);
            await DbContext.AddApiResourceAsync(newResource, cancellationToken);
        }

        [HttpPatch]
        [Authorize(Policy = "Administrator")]
        public async Task UpdateResource([FromBody] ApiResourceDto resource, CancellationToken cancellationToken)
        {
            var update = Mapper.Map<ApiResource>(resource);
            await DbContext.UpdateApiResourceAsync(update, cancellationToken);
        }
    }
}