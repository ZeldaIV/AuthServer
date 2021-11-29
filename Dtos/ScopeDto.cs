using System;
using System.Collections.Generic;

namespace AuthServer.Dtos
{
    public class ScopeDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string DisplayName { get; set; }
        public string Description { get; set; }
        public List<string> Resources { get; set; }
    }
}