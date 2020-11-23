using AuthServer.Dtos.ApiResource;
using AutoMapper;
using IdentityServer4.EntityFramework.Entities;
using ApiResource = IdentityServer4.Models.ApiResource;

namespace AuthServer.AutoMapperConfig
{
    public static class MapperConfig  
    {
        public static void Configure(IMapperConfigurationExpression config)
        {
            config.CreateMap<ApiResourceProperty, ApiResourcePropertyDto>()
                .ReverseMap()
                .ForMember(s => s.ApiResourceId, c => c.Ignore())
                .ForMember(s => s.ApiResource, d => d.Ignore());

            config.CreateMap<ApiResourceScope, ApiResourceScopeDto>()
                .ReverseMap()
                .ForMember(s => s.ApiResource, d => d.Ignore())
                .ForMember(d => d.ApiResourceId, s => s.Ignore());

            config.CreateMap<ApiResourceSecret, ApiResourceSecretDto>()
                .ReverseMap()
                .ForMember(d => d.ApiResource, d => d.Ignore())
                .ForMember(d => d.ApiResourceId, d => d.Ignore());

            config.CreateMap<ApiResourceClaim, ApiResourceClaimDto>()
                .ReverseMap()
                .ForMember(d => d.ApiResource, d => d.Ignore())
                .ForMember(d => d.ApiResourceId, d => d.Ignore());
            
            config.CreateMap<ApiResource, ApiResourceDto>()
                .ReverseMap();
            
        }
    }
}