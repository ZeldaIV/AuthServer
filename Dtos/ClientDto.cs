using System;
using System.Collections.Generic;
using AuthServer.Data.Models;

namespace AuthServer.Dtos
{
    public class ClientDto
    {
        public AuthorizationDto Authorizations { get; set; }
        public Guid Id { get; set; }
        public Guid ClientId { get; set; }
        public string ClientSecret { get; set; }
        public string DisplayName { get; set; }
        public List<string> DisplayNames { get; set; }
        public List<string> Permissions { get; set; }
        public List<string> PostLogoutRedirectUris { get; set; }
        public List<string> RedirectUris { get; set; }
        /// <summary>
        /// Impacts the requirements.
        /// </summary>
        public bool RequirePkce { get; set; }
        public string Type { get; set; }
        public bool RequireConsent { get; set; }
    }
}