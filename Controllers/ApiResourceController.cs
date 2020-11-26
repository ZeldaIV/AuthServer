using System.Collections.Generic;
using System.Linq;
using AuthServer.Dtos.ApiResource;
using AuthServer.Utilities;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    
    public class ApiResourceController : ControllerBase
    {
        
        public ApiResourceController(IControllerUtils utils) : base(utils)
        {
        }
        
        [HttpGet]
        public List<ApiResourceDto> GetApiResources()
        {
            var apiResources = DbContext.GetAllApiResources().ToList();
            
            return Mapper.Map<List<ApiResourceDto>>(apiResources);
        }

        [HttpPost]
        public void AddResource(ApiResourceDto resource)
        {

        }
    }
}