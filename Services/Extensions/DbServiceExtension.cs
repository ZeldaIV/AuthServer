using AuthServer.Services.DbServices;
using AuthServer.Services.DbServices.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace AuthServer.Services.Extensions
{
    public static class DbServiceExtension
    {
        public static void AddDbServices(this IServiceCollection services)
        {
            services
                .AddTransient<IScopeService, ScopeService>()
                .AddTransient<IUserService, UserService>()
                .AddTransient<IClientService, ClientService>()
                .AddTransient<IApplicationAuthorizationService, ApplicationAuthorizationService>()
                .AddTransient<IEmailService, EmailService>();
        }
    }
}