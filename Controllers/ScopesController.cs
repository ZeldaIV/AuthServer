using System.Collections.Generic;
using AuthServer.Dtos;
using AuthServer.Utilities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    public class ScopesController: ControllerBase
    {
        protected ScopesController(IControllerUtils utils) : base(utils)
        {
        }

        [HttpGet]
        [Authorize(Policy = "Administrator")]
        public List<ScopeDto> GetScopes()
        {
            return new List<ScopeDto>();
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public bool AddScope(ScopeDto scope)
        {
            return true;
        }
    }
}