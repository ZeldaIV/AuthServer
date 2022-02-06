using System;
using System.Security.Cryptography.X509Certificates;
using AuthServer.Configuration;
using AuthServer.Data;
using AuthServer.Data.Models;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using static OpenIddict.Abstractions.OpenIddictConstants;

namespace AuthServer.Services.Extensions
{
    public static class OpenIdDictExtensions
    {
        public static void AddOpenIdDictServices(this IServiceCollection services, IHostEnvironment env,
            TokenSigningConfiguration tokenSigningConfiguration)
        {
            services.AddOpenIddict()
                .AddCore(options =>
                {
                    // Configure OpenIddict to use the Entity Framework Core stores and models.
                    // Note: call ReplaceDefaultEntities() to replace the default entities.
                    options.UseEntityFrameworkCore()
                        .UseDbContext<ApplicationDbContext>()
                        .ReplaceDefaultEntities<ApplicationClient, ApplicationAuthorization, ApplicationScope,
                            ApplicationToken, Guid>();
                })

                // Register the OpenIddict server components.
                .AddServer(options =>
                {
                    options.AllowAuthorizationCodeFlow()
                        .RequireProofKeyForCodeExchange()
                        .AllowClientCredentialsFlow()
                        .AllowRefreshTokenFlow();

                    // Register the ASP.NET Core host and configure the ASP.NET Core-specific options.
                    options.UseAspNetCore()
                        .EnableStatusCodePagesIntegration()
                        .EnableAuthorizationEndpointPassthrough()
                        .EnableLogoutEndpointPassthrough()
                        .EnableTokenEndpointPassthrough()
                        .EnableUserinfoEndpointPassthrough();

                    options.SetAuthorizationEndpointUris("/connect/authorize")
                        .SetLogoutEndpointUris("/connect/logout")
                        .SetTokenEndpointUris("/connect/token")
                        .SetIntrospectionEndpointUris("/connect/introspect")
                        .SetUserinfoEndpointUris("/connect/userinfo");

                    if (!env.IsEnvironment("Local"))
                    {
                        ;
                        var signingCertificate = new X509Certificate2(
                            tokenSigningConfiguration.AuthServerSigningCertificatePath,
                            tokenSigningConfiguration.AuthServerSigningCertificatePassword);
                        // Register the signing and encryption credentials.
                        options.AddEncryptionCertificate(signingCertificate)
                            .AddSigningCertificate(signingCertificate)
                            .DisableAccessTokenEncryption();
                        // options.AddDevelopmentEncryptionCertificate()
                        //     .AddDevelopmentSigningCertificate();
                    }
                    else
                    {
                        options.AddEphemeralEncryptionKey()
                            .AddEphemeralSigningKey()
                            .DisableAccessTokenEncryption();
                    }
                    
                    options.RegisterScopes(
                        Scopes.Address,
                        Scopes.Email,
                        Scopes.Phone,
                        Scopes.Profile,
                        Scopes.Roles,
                        "api");
                })

                // Register the OpenIddict validation components.
                .AddValidation(options =>
                {
                    // Import the configuration from the local OpenIddict server instance.
                    options.UseLocalServer();

                    // Register the ASP.NET Core host.
                    options.UseAspNetCore();
                });
        }
    }
}