
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace AuthServer.Pages.Account {

    public class LogoutModel: PageModel {

        private SignInManager<IdentityUser> _signInManager;
        private ILogger<LogoutModel> _logger;

        public LogoutModel(SignInManager<IdentityUser> signInManager, ILogger<LogoutModel> logger) {
            this._signInManager = signInManager;
            this._logger = logger;
        }

        public string ReturnUrl { get; set; }

        public async Task<IActionResult> OnPostLogoutAsync(string returnUrl=null) {
            await _signInManager.SignOutAsync();
            _logger.LogInformation("User signed out.");
            _logger.LogInformation(ReturnUrl);
            return SignOut(new AuthenticationProperties {
                RedirectUri = "/Index"
            }, IdentityConstants.ApplicationScheme);
        }
    }
}