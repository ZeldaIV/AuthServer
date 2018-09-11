using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityServer4.EntityFramework.DbContexts;
using IdentityServer4.EntityFramework.Mappers;
using IdentityServer4.Models;
using IdentityServer4.Stores;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Admin
{
    public class DeleteClientModel : PageModel
    {
        private readonly ILogger<DeleteClientModel> _logger;
        private readonly IClientStore _clientStore;
        private readonly ConfigurationDbContext _context;

        public DeleteClientModel(
            ILogger<DeleteClientModel> logger, 
            IClientStore clientStore,
            ConfigurationDbContext context)
        {
            _logger = logger;
            _clientStore = clientStore;
            _context = context;
        }

        public async Task OnGetAsync(string id)
        {
            if (String.IsNullOrEmpty(id)) {
                ModelState.AddModelError("", "Emtpy ID.");
            }
            CurrentClient = await _clientStore.FindClientByIdAsync(id);
            if (CurrentClient == null) {
                ModelState.AddModelError("", "Could not find the requested client");
            }
        }

        public async Task<IActionResult> OnPostDelete(string id) {
            var thingy = _context.Clients.First(c => c.ClientId.Equals(id));
            CurrentClient = thingy.ToModel();
            _context.Remove(thingy);
            await _context.SaveChangesAsync();
            return RedirectToPage("ClientAdministration");
        }

        [BindProperty]
        public Client CurrentClient { get; set; }
    }
}