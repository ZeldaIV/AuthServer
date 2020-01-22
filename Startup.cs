using System;
using System.Collections.Generic;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
using AuthServer.Authorization;
using AuthServer.Configuration;
using AuthServer.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;

namespace AuthServer
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }


        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<CookiePolicyOptions>(options =>
            {
                // This lambda determines whether user consent for non-essential cookies is needed for a given request.
                options.CheckConsentNeeded = context => true;
                options.MinimumSameSitePolicy = SameSiteMode.None;
            });

            var mysqlConnectionString = Configuration.GetConnectionString("MysqlConnectionString");
            var migrationsAssembly = typeof(Startup).GetTypeInfo().Assembly.GetName().Name;

            services.AddDbContextPool<ApplicationDbContext>(
                options => options.UseMySql(mysqlConnectionString,
                    mysqlOptions =>
                    {
                        mysqlOptions.ServerVersion(new Version(10, 3, 9),
                            ServerType.MariaDb); // replace with your Server Version and Type
                        mysqlOptions.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> {1, 2, 3, 4});
                    }
                ));
            services.AddIdentity<IdentityUser, IdentityRole>()
                .AddDefaultTokenProviders()
                .AddEntityFrameworkStores<ApplicationDbContext>();

            var tokenSigning = Configuration.Get<TokenSigningConfiguration>();
            var signingCertificate = new X509Certificate2(tokenSigning.AuthServerSigningCertificatePath,
                tokenSigning.AuthServerSigningCertificatePassword);
            services.AddIdentityServer(options =>
                {
                    options.Events.RaiseErrorEvents = true;
                    options.Events.RaiseInformationEvents = true;
                    options.Events.RaiseFailureEvents = true;
                    options.Events.RaiseSuccessEvents = true;
                    // options.IssuerUri = "https://authserver.com";
                })
                .AddAspNetIdentity<IdentityUser>()
                .AddSigningCredential(signingCertificate)
                .AddConfigurationStore(options =>
                {
                    options.ConfigureDbContext = builder =>
                        builder.UseMySql(mysqlConnectionString,
                            sql =>
                            {
                                sql.MigrationsAssembly(migrationsAssembly);
                                sql.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> {1, 2, 3, 4});
                            });
                }).AddOperationalStore(options =>
                {
                    options.ConfigureDbContext = builder =>
                    {
                        builder.UseMySql(mysqlConnectionString,
                            sql =>
                            {
                                sql.MigrationsAssembly(migrationsAssembly);
                                sql.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> {1, 2, 3, 4});
                            });
                    };
                });

            services.AddSingleton<IAuthorizationHandler, AdministratorHandler>();
            services.AddAuthorization(options =>
            {
                options.AddPolicy("Administrator",
                    policy => { policy.Requirements.Add(new AdministratorRequirement()); });
            });
            services.AddAuthentication();
            services.AddCors();
            services.AddMvc(config =>
                {
                    var policy = new AuthorizationPolicyBuilder()
                        .RequireAuthenticatedUser()
                        .Build();
                    config.Filters.Add(new AuthorizeFilter(policy));
                    config.EnableEndpointRouting = false;
                })
                .SetCompatibilityVersion(CompatibilityVersion.Version_3_0);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                //app.UseDatabaseErrorPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }

            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });
            app.UseCors();
            app.UseHttpsRedirection();
            app.UseStaticFiles();

            // app.UseCookiePolicy();

            // app.UseAuthentication();
            app.UseIdentityServer();

            app.UseMvc();
        }
    }
}