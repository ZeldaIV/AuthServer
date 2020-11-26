using AuthServer.Dtos.ApiResource;
using AutoMapper;
using IdentityServer4.EntityFramework.Entities;

namespace AuthServer.AutoMapperConfig
{
    public static class MapperConfig  
    {
        public static void Configure(IMapperConfigurationExpression config)
        {
            config.CreateMap<ApiResource, ApiResourceDto>()
                .ReverseMap();
            
        }
    }
}