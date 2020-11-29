using System.Collections.Generic;

namespace AuthServer.Dtos.ApiResource
{
    public class ApiResourceDto
    {
        public bool Enabled { get; set; }
        public string Name { get; set; }
        public string DisplayName { get; set; }
        public string Description { get; set; }
        public List<string> ApiSecrets { get; set; } = new List<string>();
        public List<string> Scopes { get; set; } = new List<string>();
    }
}