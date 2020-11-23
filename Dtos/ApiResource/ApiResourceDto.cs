using System;
using System.Collections.Generic;
using IdentityServer4.EntityFramework.Entities;

namespace AuthServer.Dtos.ApiResource
{
    public class ApiResourceDto
    {
        public int Id { get; set; }
        public bool Enabled { get; set; }
        public string Name { get; set; }
        public string DisplayName { get; set; }
        public string Description { get; set; }
        public string AllowedAccessTokenSigningAlgorithms { get; set; }
        public bool ShowInDiscoveryDocument { get; set; }
        public List<ApiResourceSecretDto> Secrets { get; set; }
        public List<ApiResourceScopeDto> Scopes { get; set; }
        public List<ApiResourceClaimDto> UserClaims { get; set; }
        public List<ApiResourcePropertyDto> Properties { get; set; }
        public DateTime Created { get; set; } = DateTime.UtcNow;
        public DateTime? Updated { get; set; }
        public DateTime? LastAccessed { get; set; }
        public bool NonEditable { get; set; }
    }
}