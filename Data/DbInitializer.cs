using IdentityServer4.EntityFramework.DbContexts;

namespace AuthServer.Data {
    public static class DbInitializer {
        public static void Initialize(ApplicationDbContext context) {
            context.Database.EnsureCreated();
        }

        public static void Initialize(ConfigurationDbContext context) {
            context.Database.EnsureCreated();
        }
    }
}