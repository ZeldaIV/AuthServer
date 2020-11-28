using System.Threading.Tasks;
using AuthServer.Data;
using IdentityServer4.EntityFramework.DbContexts;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Serilog;

namespace AuthServer
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Log.Logger = new LoggerConfiguration()
                .Enrich.FromLogContext()
                .WriteTo.Console()
                .WriteTo.Seq("http://localhost:5341")
                .CreateLogger();
            
            var host = CreateWebHostBuilder(args).Build();
            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                Task.Run(async () =>
                {
                    var appDbContext = services.GetRequiredService<ApplicationDbContext>();
                    var appDbSuccess = await DbInitializer.Initialize(appDbContext);
                    if (appDbSuccess)
                        Log.Information("Db app migrations initialized");
                    else
                        Log.Error("Could not initialize app db after 5 attempts.");
                    var configurationDbContext = services.GetRequiredService<ConfigurationDbContext>();
                    var identityDbSuccess = await DbInitializer.Initialize(configurationDbContext);
                    if (identityDbSuccess)
                        Log.Information("Db identity migrations initialized");
                    else
                        Log.Error("Could not initialize identity db after 5 attempts.");
                    SeedData.EnsureSeedData(services);
                }).GetAwaiter().GetResult();
            }

            host.Run();
        }

        private static IWebHostBuilder CreateWebHostBuilder(string[] args)
        {
            return WebHost.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    config.AddCommandLine(args);
                })
                .UseWebRoot("wwwroot")
                .UseSerilog()
                .UseStartup<Startup>();
        }
    }
}