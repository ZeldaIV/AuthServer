using System;
using System.Collections.Generic;

namespace AuthServer.Dtos
{
    public class ClientDto
    {
        public Guid Id { get; set; }
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
        public string DisplayName { get; set; }
        public List<string> DisplayNames { get; set; }
        public List<string> Permissions { get; set; }
        public List<string> PostLogoutRedirectUris { get; set; }
        public List<string> RedirectUris { get; set; }

        /// <summary>
        ///     Impacts the requirements.
        /// </summary>
        public bool RequirePkce { get; set; }

        public string Type { get; set; }
        public bool RequireConsent { get; set; }
    }
}