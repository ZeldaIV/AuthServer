using System;
using System.IO;
using System.Threading.Tasks;
using AuthServer.Data;
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
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .AddJsonFile(
                    $"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Local"}.json", true)
                .Build();

            Log.Logger = new LoggerConfiguration()
                .ReadFrom.Configuration(configuration)
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
                    SeedData.EnsureSeedData(services);
                }).GetAwaiter().GetResult();
            }

            host.Run();
        }

        private static IHostBuilder CreateHostBuilder(string[] args)
        {
            return Host.CreateDefaultBuilder(args)
                .UseSerilog()
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.ConfigureAppConfiguration((context, config) =>
                        {
                            config.AddCommandLine(args);
                            config.AddJsonFile("appsettings.json");
                            if (context.HostingEnvironment.IsDevelopment())
                                config.AddJsonFile("appsettings.Development.json", true, true);
                            if (context.HostingEnvironment.IsEnvironment("Local"))
                                config.AddJsonFile("appsettings.Local.json", true, true);

                            if (context.HostingEnvironment.IsDevelopment() ||
                                context.HostingEnvironment.IsEnvironment("Local")) config.AddUserSecrets<Program>();
                        })
                        .UseWebRoot("wwwroot")
                        .UseStartup<Startup>();
                });
        }
    }
}