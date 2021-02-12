using System.Threading.Tasks;
using AuthServer.Data;
using IdentityServer4.EntityFramework.DbContexts;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
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
            
            var host = CreateHostBuilder(args).Build();
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
                        Log.Error("Could not initialize app db after 5 attempts");
                    var configurationDbContext = services.GetRequiredService<ConfigurationDbContext>();
                    var identityDbSuccess = await DbInitializer.Initialize(configurationDbContext);
                    if (identityDbSuccess)
                        Log.Information("Db identity migrations initialized");
                    else
                        Log.Error("Could not initialize identity db after 5 attempts");
                    SeedData.EnsureSeedData(services);
                }).GetAwaiter().GetResult();
            }

            host.Run();
        }

        private static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.ConfigureAppConfiguration((context, config) =>
                        {
                            config.AddCommandLine(args);
                            config.AddJsonFile("appsettings.json");
                            config.AddJsonFile("appsettings.Development.json", true, true);
                            config.AddJsonFile("appsettings.Local.json", true, true);

                            if (context.HostingEnvironment.IsDevelopment() || context.HostingEnvironment.IsEnvironment("Local"))
                            {
                                config.AddUserSecrets<Program>();
                            }
                        })
                        
                        .UseWebRoot("wwwroot")
                        .UseStartup<Startup>();
                })
                .UseSerilog();
    }
}