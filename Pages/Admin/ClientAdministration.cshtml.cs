using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using IdentityServer4.EntityFramework.DbContexts;
using IdentityServer4.EntityFramework.Mappers;
using IdentityServer4.Models;
using IdentityServer4.Services;
using IdentityServer4.Stores;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Admin
{
    public class ClientAdministrationModel : PageModel
    {
        private readonly IClientStore _clientStore;
        private readonly ConfigurationDbContext _context;
        private readonly IIdentityServerInteractionService _Interaction;
        private readonly ILogger<ClientAdministrationModel> _logger;

        public ClientAdministrationModel(
            ILogger<ClientAdministrationModel> logger,
            ConfigurationDbContext context,
            IClientStore clientStore,
            IIdentityServerInteractionService interaction)
        {
            _logger = logger;
            _context = context;
            _clientStore = clientStore;
            _Interaction = interaction;
        }

        public void OnGet(string secret)
        {
            var cl = _context.Clients;
            _logger.LogInformation($"The clients: {cl}");
            Clients = cl.Include(c => c.PostLogoutRedirectUris)
                .Include(c => c.RedirectUris)
                .Include(c => c.AllowedScopes)
                .Include(c => c.AllowedGrantTypes)
                .Select(c => c.ToModel()).ToList();
        }

        public async Task OnPostCreateClientAsync() {
            var secret = Guid.NewGuid().ToString().Sha256();
            if(ModelState.IsValid) {
                using (_context) {
                    var client = new Client {
                        ClientId = Guid.NewGuid().ToString(),
                        ClientName = Input.ClientName,
                        ClientSecrets = { new Secret(secret) },
                        RedirectUris = { Input.RedirectUri },
                        PostLogoutRedirectUris = { Input.PostLogoutRedirectUri }
                    };
                    await _context.AddAsync(client.ToEntity());
                    await _context.SaveChangesAsync();
                    FormResult = secret;
                }
            }
            Response.Redirect($"/Admin/ClientAdministration/{secret}", true);
        }

        [BindProperty]
        public InputModel Input { get; set; }

        [BindProperty]
        public List<Client> Clients { get; set; }
        [TempData]
        public string FormResult { get; set; }

        public class InputModel {
            [Display(Name="Client name:")]
            public string ClientName { get; set; }
            [Display(Name="Redirect Uri:")]
            public string RedirectUri { get; set; }
            [Display(Name="Logout redirect:")]
            public string PostLogoutRedirectUri { get; set; }
            
        }
    }
}