using System;

namespace AuthServer.Data.Models
{
    public class ApplicationClaimType
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Value { get; set; }
        public string Description { get; set; }
    }
}