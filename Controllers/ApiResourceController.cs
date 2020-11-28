using System.Collections.Generic;
using System.Linq;
using AuthServer.Dtos.ApiResource;
using AuthServer.Utilities;
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

        [HttpPost]
        [Authorize(Policy = "Administrator")]
        public void AddResource(ApiResourceDto resource)
        {

        }
    }
}