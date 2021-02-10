using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
using AuthServer.Authorization;
using AuthServer.AutoMapperConfig;
using AuthServer.Configuration;
using AuthServer.Data;
using AuthServer.Utilities;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.AspNetCore.StaticFiles.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using Serilog;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace AuthServer
{
    public class Startup
    {
        private readonly IHostEnvironment _env;
        private const string Cors = "local";

        public Startup(IConfiguration configuration, IHostEnvironment env)
        {
            _env = env;
            Configuration = configuration;
        }


        public IConfiguration Configuration { get; }


        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // services.Configure<CookiePolicyOptions>(options =>
            // {
            //     // This lambda determines whether user consent for non-essential cookies is needed for a given request.
            //     options.CheckConsentNeeded = context => true;
            //     options.MinimumSameSitePolicy = SameSiteMode.None;
            // });


            var mysqlConnectionString = Configuration.GetConnectionString("MysqlConnectionString");
            var migrationsAssembly = typeof(Startup).GetTypeInfo().Assembly.GetName().Name;
            var dbServerVersion = new MariaDbServerVersion(new Version(10, 3, 9));

            services.AddAutoMapper(MapperConfig.Configure);
            
            services.AddDbContextPool<ApplicationDbContext>(
                options =>
                {
                    options.UseMySql(mysqlConnectionString, dbServerVersion,
                        mysqlOptions =>
                        {
                            mysqlOptions.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> {1, 2, 3, 4});
                        }
                    );
                });
            services.AddIdentity<IdentityUser, IdentityRole>()
                .AddDefaultTokenProviders()
                .AddEntityFrameworkStores<ApplicationDbContext>();

            services.ConfigureApplicationCookie(o =>
            {
                o.LoginPath = "/login";
            });

            if (!_env.IsEnvironment("SwaggerGen"))
            {
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
                            builder.UseMySql(mysqlConnectionString, dbServerVersion,
                                sql =>
                                {
                                    sql.MigrationsAssembly(migrationsAssembly);
                                    sql.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> {1, 2, 3, 4});
                                });
                    }).AddOperationalStore(options =>
                    {
                        options.ConfigureDbContext = builder =>
                        {
                            builder.UseMySql(mysqlConnectionString, dbServerVersion,
                                sql =>
                                {
                                    sql.MigrationsAssembly(migrationsAssembly);
                                    sql.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> {1, 2, 3, 4});
                                });
                        };
                    });
            }
            
            services.AddSingleton<IAuthorizationHandler, AdministratorHandler>()
                .AddScoped<IIdentityServerDbContext, IdentityServerDbContext>()
                .AddScoped<IStores, Stores>()
                .AddScoped<IControllerUtils, ControllerUtils>();
            
            
            
            
            services.AddAuthorization(options =>
            {
                options.AddPolicy("Administrator",
                    policy => { policy.Requirements.Add(new AdministratorRequirement()); });
            });
            services.AddAuthentication();
            services.AddCors(o =>
            {
                o.AddPolicy(Cors, builder => { builder.WithOrigins("https://localhost"); });
            });
            // services.AddControllers(config =>
            // {
            //     var policy = new AuthorizationPolicyBuilder()
            //         .RequireAuthenticatedUser()
            //         .Build();
            //     config.Filters.Add(new AuthorizeFilter(policy));
            //     config.EnableEndpointRouting = false;
            // });

            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "wwwroot";
            });

            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "AuthServer API", Version = "v1", Description = "AuthServer Idp"});
                c.DocumentFilter<DocumentFiler>();
            });

            services.AddMvc(config =>
                {
                    var policy = new AuthorizationPolicyBuilder()
                        .RequireAuthenticatedUser()
                        .Build();
                    config.Filters.Add(new AuthorizeFilter(policy));
                    config.EnableEndpointRouting = false;
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app)
        {
            if (_env.IsDevelopment())
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
            
            app.UseHttpsRedirection();
            app.UseSerilogRequestLogging();
            

            // app.UseCookiePolicy();
            
            
            app.UseIdentityServer();
            app.UseRouting();
            app.UseAuthorization();
            app.UseCors(Cors);

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "api/{controller}/{action=Index}/{id?}");
            });
            

            var appSubPath = "wwwroot";
            var distFolder = Path.Combine(Directory.GetCurrentDirectory(), appSubPath);
            if (!Directory.Exists(distFolder))
            {
                Log.Error($"Unable to host spa app in: {distFolder}, folder not found");
                return;
            }

            Log.Information($"Hosting '{appSubPath}' static files from folder: {distFolder}");
            var staticFileOptions = new StaticFileOptions(new SharedOptions
            {
                FileProvider = new PhysicalFileProvider(distFolder)
            });
            app.UseStaticFiles(staticFileOptions);
            app.UseSpaStaticFiles(staticFileOptions);
            app.UseSpa(spa =>
            {
                spa.Options.SourcePath = "wwwroot";
                spa.Options.DefaultPageStaticFileOptions = staticFileOptions;
            });

            app.UseSwagger();
            app.UseMvc();
        }
    }

    public class DocumentFiler : IDocumentFilter
    {
        public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
        {
            swaggerDoc.Servers = new List<OpenApiServer>{ new() { Url = "https://localhost"}};
        }
    }
}