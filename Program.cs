using System.Threading.Tasks;
using AuthServer.Data;
using IdentityServer4.EntityFramework.DbContexts;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace AuthServer
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = CreateWebHostBuilder(args).Build();
            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                var logger = services.GetRequiredService<ILogger<Program>>();
                Task.Run(async () =>
                {
                    var appDbContext = services.GetRequiredService<ApplicationDbContext>();
                    var appDbSuccess = await DbInitializer.Initialize(appDbContext);
                    if (appDbSuccess)
                        logger.LogInformation("Db app migrations initialized");
                    else
                        logger.LogError("Could not initialize app db after 5 attempts.");
                    var configurationDbContext = services.GetRequiredService<ConfigurationDbContext>();
                    var identityDbSuccess = await DbInitializer.Initialize(configurationDbContext);
                    if (identityDbSuccess)
                        logger.LogInformation("Db identity migrations initialized");
                    else
                        logger.LogError("Could not initialize identity db after 5 attempts.");
                    SeedData.EnsureSeedData(services);
                }).GetAwaiter().GetResult();
            }

            host.Run();
        }

        private static IWebHostBuilder CreateWebHostBuilder(string[] args)
        {
            return WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
        }
    }
}