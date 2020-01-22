using System.Data.Common;
using System.Threading.Tasks;
using IdentityServer4.EntityFramework.DbContexts;
using Microsoft.EntityFrameworkCore;

namespace AuthServer.Data
{
    public static class DbInitializer
    {
        public static async Task<bool> Initialize(ApplicationDbContext context)
        {
            var connection = context.Database.GetDbConnection();
            var result = await InitilizeDb(connection);
            if (result) await context.Database.MigrateAsync();
            return result;
        }

        public static async Task<bool> Initialize(ConfigurationDbContext context)
        {
            var connection = context.Database.GetDbConnection();
            var result = await InitilizeDb(connection);
            if (result) await context.Database.MigrateAsync();
            return result;
        }

        public static async Task<bool> InitilizeDb(DbConnection connection)
        {
            var attempts = 5;
            var attempt = 0;
            while (true)
            {
                if (attempt > 0) await Task.Delay(15000);
                try
                {
                    connection.Open();
                    return true;
                }
                catch
                {
                    attempt++;
                    if (attempt >= attempts) return false;
                }
            }
        }
    }
}