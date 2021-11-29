using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using AuthServer.Authorization;
using AuthServer.Configuration;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.Extensions.Services;
using AuthServer.Utilities;
using AuthServer.Utilities.Swagger;
using HotChocolate.AspNetCore;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
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
using Newtonsoft.Json.Converters;
using OpenIddict.Abstractions;
using Serilog;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace AuthServer
{
    public class Startup
    {
        private const string Cors = "local";
        private readonly IHostEnvironment _env;

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
            AuthServerTypeAdapterConfig.Configure();

            var mysqlConnectionString = Configuration.GetConnectionString("MysqlConnectionString");
            var migrationsAssembly = typeof(Startup).GetTypeInfo().Assembly.GetName().Name;
            var dbServerVersion = new MariaDbServerVersion(new Version(10, 6, 4));

            Action<DbContextOptionsBuilder> dbOptions = options =>
            {
                options.UseMySql(mysqlConnectionString, dbServerVersion,
                    builder =>
                    {
                        builder.MigrationsAssembly(migrationsAssembly);
                        builder.EnableRetryOnFailure(5, new TimeSpan(0, 0, 10), new List<int> { 1, 2, 3, 4 });
                    }
                );
                options
                    .UseOpenIddict<ApplicationClient, ApplicationAuthorization, ApplicationScope, ApplicationToken,
                        Guid>();
            };
            services.AddDbContext<ApplicationDbContext>(dbOptions);
            services.AddPooledDbContextFactory<ApplicationDbContext>(dbOptions);

            services.AddHostedService<TestData>();

            services.AddIdentity<ApplicationUser, ApplicationRole>()
                .AddDefaultTokenProviders()
                .AddEntityFrameworkStores<ApplicationDbContext>();

            services.Configure<IdentityOptions>(options =>
            {
                options.ClaimsIdentity.UserNameClaimType = OpenIddictConstants.Claims.Name;
                options.ClaimsIdentity.UserIdClaimType = OpenIddictConstants.Claims.Subject;
                options.ClaimsIdentity.RoleClaimType = OpenIddictConstants.Claims.Role;
            });

            // services.ConfigureApplicationCookie(o => { o.LoginPath = "/login"; });

            services.AddDbServices();

            services.AddGraphQlServices();

            services.AddSingleton<IAuthorizationHandler, AdministratorHandler>()
                .AddScoped<IStores, Stores>()
                .AddScoped<IControllerUtils, ControllerUtils>();

            services.AddOpenIdDictServices(_env, Configuration.Get<TokenSigningConfiguration>());

            services.AddAuthorization(options =>
            {
                options.AddPolicy("Administrator",
                    policy => { policy.Requirements.Add(new AdministratorRequirement()); });
            });
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, opts => { opts.LoginPath = "/login"; });
            services.AddCors(o => { o.AddPolicy(Cors, builder => { builder.WithOrigins("https://localhost"); }); });

            services.AddSpaStaticFiles(configuration => { configuration.RootPath = "wwwroot"; });

            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1",
                    new OpenApiInfo { Title = "AuthServer API", Version = "v1", Description = "AuthServer Idp" });
                c.DocumentFilter<DocumentFiler>();
                c.DocumentFilter<ModelFilter>();
                c.UseInlineDefinitionsForEnums();
            });

            services.AddSwaggerGenNewtonsoftSupport();

            services.AddGraphQL();

            services.AddControllers(o =>
            {
                var policy = new AuthorizationPolicyBuilder()
                    .RequireAuthenticatedUser()
                    .Build();
                o.Filters.Add(new AuthorizeFilter(policy));
                o.EnableEndpointRouting = true;
            }).AddNewtonsoftJson(o =>
                o.SerializerSettings.Converters.Add(new StringEnumConverter())
            );
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


            //app.UseHttpsRedirection();
            app.UseSerilogRequestLogging();


            app.UseCookiePolicy();


            app.UseRouting();
            app.UseCors(Cors);
            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    "api",
                    "api/{controller=Account}/{action=Index}/{id?}");
                endpoints.MapControllerRoute(
                    "connect",
                    "connect/{controller=Authorization}/{action=Index}/{id?}");

                endpoints.MapGraphQL()
                    .WithOptions(new GraphQLServerOptions
                    {
                        // Enable Introspection
                        EnableSchemaRequests = true,
                        // Enable Banana Cake Pop
                        Tool =
                        {
                            Enable = _env.IsDevelopment()
                        }
                    });
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
            app.UseSpaStaticFiles(staticFileOptions);
            app.UseSpa(spa =>
            {
                spa.Options.SourcePath = "wwwroot";
                spa.Options.DefaultPageStaticFileOptions = staticFileOptions;
            });
            app.UseSwagger();
        }
    }

    public class DocumentFiler : IDocumentFilter
    {
        public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
        {
            swaggerDoc.Servers = new List<OpenApiServer> { new() { Url = "https://localhost/api" } };
            var oldPaths = swaggerDoc.Paths.ToDictionary(entry => entry.Key,
                entry => entry.Value);
            foreach (var (key, value) in oldPaths)
            {
                swaggerDoc.Paths.Remove(key);
                swaggerDoc.Paths.Add(key.Replace("/api", ""), value);
            }
        }
    }

    public class ModelFilter : IDocumentFilter
    {
        public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
        {
            foreach (var type in Assembly.GetExecutingAssembly().GetTypes())
                if (type.IsClass || type.IsInterface)
                    if (type.GetCustomAttribute(typeof(GenerateModelAttribute)) != null)
                        context.SchemaGenerator.GenerateSchema(type, context.SchemaRepository);
        }
    }
}