using System;
using System.Linq;
using System.Security.Claims;
using AuthServer.Configuration;
using AuthServer.Data.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Serilog;

namespace AuthServer.Data
{
    public class SeedData
    {
        public static async void EnsureSeedData(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.GetRequiredService<IServiceScopeFactory>().CreateScope();

            var configuration = scope.ServiceProvider.GetService<IConfiguration>();
            var adminConfigration = configuration.Get<AdministrationConfiguration>();
            var administrator = adminConfigration.AuthServerAdministrator;
            var password = adminConfigration.AuthServerAdministratorPassword;

            var userMgr = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
            var admin = await userMgr.FindByNameAsync(administrator);
            if (admin == null)
            {
                admin = new ApplicationUser(administrator);
                var result = await userMgr.CreateAsync(admin, password);
                if (!result.Succeeded) throw new Exception(result.Errors.First().Description);
                result = userMgr.AddClaimsAsync(admin, new[]
                {
                    new Claim(ClaimTypes.Name, administrator),
                    new Claim(ClaimTypes.Role, "Administrator")
                }).Result;
                if (!result.Succeeded) throw new Exception(result.Errors.First().Description);
            }
            else
            {
                Log.Information($@"Administrator: {administrator} already exists, will not create");
            }
        }
    }
}