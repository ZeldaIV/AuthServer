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

            config.CreateMap<Client, ClientDto>()
                .ReverseMap()
                .ForMember(d => d.Id, s => s.AllowNull())
                .ForMember(d => d.Properties, s => s.Ignore())
                .ForMember(d => d.ProtocolType, s => s.Ignore())
                .ForMember(d => d.RequireClientSecret, s => s.Ignore())
                .ForMember(d => d.RequireConsent, s => s.Ignore())
                .ForMember(d => d.AllowRememberConsent, s => s.Ignore())
                .ForMember(d => d.AlwaysIncludeUserClaimsInIdToken, s => s.Ignore())
                .ForMember(d => d.RequirePkce, s => s.Ignore())
                .ForMember(d => d.AllowPlainTextPkce, s => s.Ignore())
                .ForMember(d => d.RequireRequestObject, s => s.Ignore())
                .ForMember(d => d.AllowAccessTokensViaBrowser, s => s.Ignore())
                .ForMember(d => d.FrontChannelLogoutUri, s => s.Ignore())
                .ForMember(d => d.FrontChannelLogoutSessionRequired, s => s.Ignore())
                .ForMember(d => d.BackChannelLogoutUri, s => s.Ignore())
                .ForMember(d => d.BackChannelLogoutSessionRequired, s => s.Ignore())
                .ForMember(d => d.AllowOfflineAccess, s => s.Ignore())
                .ForMember(d => d.IdentityTokenLifetime, s => s.Ignore())
                .ForMember(d => d.AllowedIdentityTokenSigningAlgorithms, s => s.Ignore())
                .ForMember(d => d.AccessTokenLifetime, s => s.Ignore())
                .ForMember(d => d.AuthorizationCodeLifetime, s => s.Ignore())
                .ForMember(d => d.ConsentLifetime, s => s.Ignore())
                .ForMember(d => d.AbsoluteRefreshTokenLifetime, s => s.Ignore())
                .ForMember(d => d.SlidingRefreshTokenLifetime, s => s.Ignore())
                .ForMember(d => d.RefreshTokenUsage, s => s.Ignore())
                .ForMember(d => d.UpdateAccessTokenClaimsOnRefresh, s => s.Ignore())
                .ForMember(d => d.RefreshTokenExpiration, s => s.Ignore())
                .ForMember(d => d.AccessTokenType, s => s.Ignore())
                .ForMember(d => d.EnableLocalLogin, s => s.Ignore())
                .ForMember(d => d.IdentityProviderRestrictions, s => s.Ignore())
                .ForMember(d => d.IncludeJwtId, s => s.Ignore())
                .ForMember(d => d.Claims, s => s.Ignore())
                .ForMember(d => d.AlwaysSendClientClaims, s => s.Ignore())
                .ForMember(d => d.ClientClaimsPrefix, s => s.Ignore())
                .ForMember(d => d.PairWiseSubjectSalt, s => s.Ignore())
                .ForMember(d => d.AllowedCorsOrigins, s => s.Ignore())
                .ForMember(d => d.UserSsoLifetime, s => s.Ignore())
                .ForMember(d => d.UserCodeType, s => s.Ignore())
                .ForMember(d => d.DeviceCodeLifetime, s => s.Ignore())
                .ForMember(d => d.NonEditable, s => s.Ignore());
        }
    }
}