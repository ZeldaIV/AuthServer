using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AuthServer.Data;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
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
            // var connectionString = Configuration.GetConnectionString("DefaultConnection");
            var mysqlConnectionString = Configuration.GetConnectionString("MysqlConnectionString");
            var migrationsAssembly = typeof(Startup).GetTypeInfo().Assembly.GetName().Name;
            // services.AddDbContext<ApplicationDbContext>(options =>
            //     options.UseSqlite(
            //         connectionString));
            services.AddDbContextPool<ApplicationDbContext>(
                options => options.UseMySql(mysqlConnectionString,
                    mysqlOptions =>
                    {
                        mysqlOptions.ServerVersion(new Version(10, 3, 8), ServerType.MySql); // replace with your Server Version and Type
                    }
            ));
            services.AddIdentity<IdentityUser, IdentityRole>()
                .AddDefaultTokenProviders()
                .AddEntityFrameworkStores<ApplicationDbContext>();

            var signingCertificate = new X509Certificate2("./certificates/SigningCertificate.pfx", "ValidatedKey");
            services.AddIdentityServer(options =>
                {
                    options.Events.RaiseErrorEvents = true;
                    options.Events.RaiseInformationEvents = true;
                    options.Events.RaiseFailureEvents = true;
                    options.Events.RaiseSuccessEvents = true;
                })
                    .AddAspNetIdentity<IdentityUser>()
                    .AddSigningCredential(signingCertificate)
                    .AddConfigurationStore(options => {
                        options.ConfigureDbContext = builder => 
                            builder.UseMySql(mysqlConnectionString,
                            sql => sql.MigrationsAssembly(migrationsAssembly));
                    })
                    // .AddInMemoryClients(Config.GetClients())
                    // .AddInMemoryApiResources(Config.GetApiResources())
                    // .AddInMemoryIdentityResources(Config.GetIdentityResources())
                    ;

            services.AddAuthentication();
            services.AddMvc()
                .SetCompatibilityVersion(CompatibilityVersion.Version_2_1);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseDatabaseErrorPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();
            // app.UseCookiePolicy();
            
            // app.UseAuthentication();
            app.UseIdentityServer();

            app.UseMvc();
        }
    }
}
