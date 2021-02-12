using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;
using AuthServer.Utilities;
using IdentityServer4.EntityFramework.Entities;
using Mapster;
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
            return DbContext.GetAllApiResources().ToList().Adapt<List<ApiResourceDto>>();
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public async Task AddResource([FromBody] ApiResourceDto resource, CancellationToken cancellationToken)
        {
            await DbContext.AddApiResourceAsync(resource.Adapt<ApiResource>(), cancellationToken);
        }

        [HttpPatch]
        [Authorize(Policy = "Administrator")]
        public async Task UpdateResource([FromBody] ApiResourceDto resource, CancellationToken cancellationToken)
        {
            await DbContext.UpdateApiResourceAsync(resource.Adapt<ApiResource>(), cancellationToken);
        }
    }
}