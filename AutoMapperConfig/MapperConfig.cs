using AuthServer.Dtos;
using AutoMapper;
using IdentityServer4.EntityFramework.Entities;

namespace AuthServer.AutoMapperConfig
{
    public static class MapperConfig  
    {
        public static void Configure(IMapperConfigurationExpression config)
        {
            config.CreateMap<ApiResource, ApiResourceDto>()
                .ReverseMap()
                .ForMember(d => d.Id, s => s.AllowNull())
                .ForMember(d => d.Properties, s => s.Ignore())
                .ForMember(d => d.Updated, s => s.Ignore())
                .ForMember(d => d.LastAccessed, s => s.Ignore())
                .ForMember(d => d.NonEditable, s => s.Ignore())
                .ForMember(d => d.ShowInDiscoveryDocument, s => s.Ignore())
                .ForMember(d => d.AllowedAccessTokenSigningAlgorithms, s => s.Ignore());
        }
    }
}