

using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using AuthServer.Configuration;
using IdentityModel;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace AuthServer.Data
{

    public class SeedData
    {
        public static async void EnsureSeedData(IServiceProvider serviceProvider)
        {


            using (var scope = serviceProvider.GetRequiredService<IServiceScopeFactory>().CreateScope())
            {
                var logger = scope.ServiceProvider.GetRequiredService<ILogger<SeedData>>();
                var context = scope.ServiceProvider.GetService<ApplicationDbContext>();

                var configuration = scope.ServiceProvider.GetService<IConfiguration>();
                var adminConfigration = configuration.Get<AdministrationConfiguration>();
                var administrator = adminConfigration.AuthServerAdministrator;
                var password = adminConfigration.AuthServerAdministratorPassword;

                var userMgr = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();
                var admin = await userMgr.FindByNameAsync(administrator);
                if (admin == null)
                {
                    admin = new IdentityUser(administrator);
                    var result = await userMgr.CreateAsync(admin, password);
                    if (!result.Succeeded)
                    {
                        throw new Exception(result.Errors.First().Description);
                    }
                    result = userMgr.AddClaimsAsync(admin, new Claim[]{
                        new Claim(JwtClaimTypes.Name, administrator),
                        new Claim(ClaimTypes.Role, "Administrator")
                        }).Result;
                    if (!result.Succeeded)
                    {
                        throw new Exception(result.Errors.First().Description);

                    }
                }
                else
                {
                    logger.LogInformation($@"Administrator: {administrator} already exists, will not create");
                }
            }
        }
    }
}