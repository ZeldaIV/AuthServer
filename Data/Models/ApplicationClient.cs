using System;
using OpenIddict.EntityFrameworkCore.Models;

namespace AuthServer.Data.Models
{
    public class ApplicationClient : OpenIddictEntityFrameworkCoreApplication<Guid, ApplicationAuthorization,
        ApplicationToken>
    {
    }
}