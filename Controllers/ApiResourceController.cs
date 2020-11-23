using System.Collections.Generic;
using System.Linq;
using AuthServer.Data;
using AuthServer.Dtos.ApiResource;
using AutoMapper;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ApiResourceController
    {
        private readonly IIdentityServerDbContext _context;
        private readonly IMapper _mapper;

        public ApiResourceController(IIdentityServerDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }
        
        [HttpGet]
        public List<ApiResourceDto> GetApiResources()
        {
            var apiResources = _context.GetAllApiResources().ToList();
            
            return _mapper.Map<List<ApiResourceDto>>(apiResources);
        }

        [HttpPost]
        public void AddResource(ApiResourceDto resource)
        {
            
        }
    }
}