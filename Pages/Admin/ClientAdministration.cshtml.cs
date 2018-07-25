using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using AuthServer;
using IdentityServer4.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Admin
{
    public class ClientAdministrationModel : PageModel
    {
        private readonly ILogger<ClientAdministrationModel> logger;

        public ClientAdministrationModel(ILogger<ClientAdministrationModel> logger)
        {
            this.logger = logger;
        }

        public void OnGet()
        {
            Clients = Config.GetClients().ToList();
        }

        [BindProperty]
        public InputModel Input { get; set; }

        [BindProperty]
        public List<Client> Clients { get; set; }

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