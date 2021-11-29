using System;
using Microsoft.AspNetCore.Identity;

namespace AuthServer.Data.Models
{
    public class ApplicationUser: IdentityUser<Guid>
    {
        public ApplicationUser(string userName): base(userName)
        {
            
        }
    }
}