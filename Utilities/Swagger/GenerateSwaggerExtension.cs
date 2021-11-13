using System;
using Microsoft.Extensions.DependencyInjection;

namespace AuthServer.Utilities.Swagger
{
    public static class GenerateSwaggerExtension
    {
        public static void AddIdentityServer(this IServiceCollection services, Action<SwaggerSetup> setupAction)
        {
            
        }
    }
}