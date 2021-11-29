using System;

namespace AuthServer.Dtos
{
    public class ClaimDto
    {
        public Guid Id { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public string Value { get; set; }
        
    }
}