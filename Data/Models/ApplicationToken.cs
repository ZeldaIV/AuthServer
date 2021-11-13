using System;
using OpenIddict.EntityFrameworkCore.Models;

namespace AuthServer.Data.Models
{
    public class ApplicationToken : OpenIddictEntityFrameworkCoreToken<Guid, ApplicationClient,
        ApplicationAuthorization>
    {
    }
}