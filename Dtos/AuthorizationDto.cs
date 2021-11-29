using System;
using System.Collections.Generic;
using AuthServer.Data.Models;

namespace AuthServer.Dtos
{
    public class AuthorizationDto
    {
        public Guid Id { get; set; }
        public ApplicationClient Application { get; set; }
        public List<string> Scopes { get; set; }
        public string Status { get; set; }
        public string Subject { get; set; }
        public DateTime? CreationDate { get; set; }
        public string Type { get; set; }
    }
}