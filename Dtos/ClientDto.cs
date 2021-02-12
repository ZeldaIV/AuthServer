using System;
using System.Collections.Generic;

namespace AuthServer.Dtos
{
    public class ClientDto
    {
        public int? Id { get; set; }
        public string ClientId { get; set; }
        public bool Enabled { get; set; }
        public string ClientName { get; set; }
        public string Description { get; set; }
        public string ClientUri { get; set; }
        public string LogoUri { get; set; }
        public List<string> ClientSecrets { get; set; }
        public List<string> AllowedGrantTypes { get; set; }
        public List<string> RedirectUris { get; set; }
        public List<string> AllowedScopes { get; set; }
        public List<string> PostLogoutRedirectUris { get; set; }
        public DateTime Created { get; set; }
        public DateTime? Updated { get; set; }
        public DateTime? LastAccessed { get; set; }
    }
}