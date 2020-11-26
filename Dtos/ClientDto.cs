using System;
using System.Collections.Generic;

namespace AuthServer.Dtos
{
    public class ClientDto
    {
        public Guid ClientId { get; set; }
        public bool Enabled { get; set; }
        public List<string> ClientSecrets { get; set; }
        public GrantTypesDto AllowedGrantTypes { get; set; }
        public List<string> RedirectUris { get; set; }
        public List<string> AllowedScopes { get; set; }
        public List<string> PostLogoutRedirectUris { get; set; }
    }

    public class GrantTypesDto
    {
        public const string AuthorizationCode = "authorization_code";
        public const string ClientCredentials = "client_credentials";
    }
}