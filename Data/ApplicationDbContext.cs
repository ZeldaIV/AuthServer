using System;
using System.Collections.Generic;
using System.IO;
using AuthServer.Data.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace AuthServer.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, Guid>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<ApplicationClient> ApplicationClients { get; set; }
        public DbSet<ApplicationAuthorization> ApplicationAuthorizations { get; set; }
        public DbSet<ApplicationScope> ApplicationScopes { get; set; }
        public DbSet<ApplicationClaimType> ClaimTypes { get; set; }
        public DbSet<EmailServer> EmailServers { get; set; }
    }

    public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .Build();


            var connectionString = configuration.GetConnectionString("MysqlConnectionString");
            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
            optionsBuilder.UseMySql(connectionString, new MariaDbServerVersion(new Version(10, 3, 9)),
                mysqlOptions =>
                {
                    mysqlOptions.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> { 1, 2, 3, 4 });
                });
            optionsBuilder
                .UseOpenIddict<ApplicationClient, ApplicationAuthorization, ApplicationScope, ApplicationToken, Guid>();
            return new ApplicationDbContext(optionsBuilder.Options);
        }
    }
}