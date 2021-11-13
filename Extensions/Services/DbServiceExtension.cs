using AuthServer.DbServices;
using AuthServer.DbServices.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace AuthServer.Extensions.Services
{
    public static class DbServiceExtension
    {
        public static void AddDbServices(this IServiceCollection services)
        {
            services
                .AddTransient<IScopeService, ScopeService>()
                .AddTransient<IUserService, UserService>()
                .AddTransient<IClientService, ClientService>()
                .AddTransient<IApplicationAuthorizationService, ApplicationAuthorizationService>();
        }
    }
}