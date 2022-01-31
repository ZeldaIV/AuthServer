using System;
using System.Collections.Generic;
using AuthServer.Data.Models;
using OpenIddict.Abstractions;

namespace AuthServer.Constants;

public static class Predefined
{
    public static List<string> Scopes =>
        new()
        {
            OpenIddictConstants.Scopes.Address,
            OpenIddictConstants.Scopes.Email,
            OpenIddictConstants.Scopes.Phone,
            OpenIddictConstants.Scopes.Profile,
            OpenIddictConstants.Scopes.Roles,
        };

    public static List<ApplicationScope> ApplicationScopes =>
        new()
        {
            new ApplicationScope
            {
                Id = Guid.Parse("2B572397-46BA-461D-A86E-95462D63DF1F"),
                Description = "The users address",
                Name = OpenIddictConstants.Scopes.Address,
                DisplayName = OpenIddictConstants.Scopes.Address
            },
            new ApplicationScope
            {
                Id = Guid.Parse("F225C036-EECB-4436-8F39-3DD48819364E"),
                Description = "The users email address",
                Name = OpenIddictConstants.Scopes.Email,
                DisplayName = OpenIddictConstants.Scopes.Email
            },
            new ApplicationScope
            {
                Id = Guid.Parse("D743A901-1C0F-46E7-A540-2666F73C6013"),
                Description = "The users phone number",
                Name = OpenIddictConstants.Scopes.Phone,
                DisplayName = OpenIddictConstants.Scopes.Phone
            },
            new ApplicationScope
            {
                Id = Guid.Parse("F8DB7B5D-2306-43ED-97DF-BDC760913630"),
                Description = "The users profile, a collection of information about the user",
                Name = OpenIddictConstants.Scopes.Profile,
                DisplayName = OpenIddictConstants.Scopes.Profile
            },
            new ApplicationScope
            {
                Id = Guid.Parse("4FDACEF6-F94B-4214-8C46-650E81A21057"),
                Description = "Roles associated with the user",
                Name = OpenIddictConstants.Scopes.Roles,
                DisplayName = OpenIddictConstants.Scopes.Roles
            }
        };
}