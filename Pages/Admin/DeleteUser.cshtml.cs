using System.Threading.Tasks;
using IdentityServer4.Stores;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Admin
{
    public class DeleteUserModel : PageModel
    {
        private readonly IClientStore _clientStore;
        private readonly ILogger<DeleteUserModel> _logger;
        private readonly UserManager<IdentityUser> _userManager;

        public DeleteUserModel(
            ILogger<DeleteUserModel> logger,
            IClientStore clientStore,
            UserManager<IdentityUser> userManager)
        {
            _logger = logger;
            _clientStore = clientStore;
            _userManager = userManager;
        }

        [BindProperty] public IdentityUser CurrentUser { get; set; }

        public async Task OnGet(string id)
        {
            CurrentUser = await _userManager.FindByIdAsync(id);
        }

        public async Task<IActionResult> OnPostDelete(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            var result = await _userManager.DeleteAsync(user);
            if (!result.Succeeded) _logger.LogError(new EventId(1), $"An error occured deleting {CurrentUser}");
            return RedirectToPage("UserAdministration");
        }
    }
}