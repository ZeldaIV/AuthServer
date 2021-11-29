using System;
using System.Collections.Generic;

namespace AuthServer.GraphQL.User.Types.Inputs
{
    public class UserClaimsInput
    {
        public Guid UserId { get; set; }
        public List<Guid> ClaimIds { get; set; }
    }
}