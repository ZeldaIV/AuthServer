using System.Collections.Generic;
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
    public class ScopesController: ControllerBase
    {
        public ScopesController(IControllerUtils utils) : base(utils)
        {
        }

        [HttpGet]
        [Authorize(Policy = "Administrator")]
        public List<ScopeDto> GetScopes(CancellationToken cancellationToken)
        {
            return DbContext.GetScopes().Adapt<List<ScopeDto>>();
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public async Task<bool> AddScope([FromBody] ScopeDto scope, CancellationToken cancellationToken)
        {
            await DbContext.AddScope(scope.Adapt<ApiScope>(), cancellationToken);
            return true;
        }
    }
}