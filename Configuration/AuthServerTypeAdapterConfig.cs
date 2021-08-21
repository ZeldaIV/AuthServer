using Mapster;

namespace AuthServer.Configuration
{
    public static class AuthServerTypeAdapterConfig
    {
        public static void Configure()
        {
            var cfg = TypeAdapterConfig.GlobalSettings;
            cfg.ConfigureUser();
        }
    }

    internal static class UserMap
    {
        internal static void ConfigureUser(this TypeAdapterConfig cfg)
        {

        }
    } 
}