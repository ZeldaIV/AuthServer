using System;
using OpenIddict.EntityFrameworkCore.Models;

namespace AuthServer.Data.Models
{
    public class
        ApplicationAuthorization : OpenIddictEntityFrameworkCoreAuthorization<Guid, ApplicationClient, ApplicationToken>
    {
    }
}