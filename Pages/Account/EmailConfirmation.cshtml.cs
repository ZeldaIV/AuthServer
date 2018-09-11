using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Account
{
    public class EmailConfirmationModel : PageModel
    {
        private readonly ILogger<EmailConfirmationModel> _logger;
        private readonly UserManager<IdentityUser> _userManager;

        public EmailConfirmationModel(
            ILogger<EmailConfirmationModel> logger, 
            UserManager<IdentityUser> userManager) {
            this._logger = logger;
            this._userManager = userManager;
        }
        

        public void OnGet()
        {
        }

        public async Task<IActionResult> OnGetConfirmEmailAsync(string userId, string code) {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) {
                return Redirect("Error");
            }
            var result = await _userManager.ConfirmEmailAsync(user, code);
            
            if (result.Succeeded) {
                var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
                return RedirectToPage("/Account/PasswordSetter", "SetPassword", new { userId=userId, token = resetToken});
            }
            
            return Redirect("");
        }
    }
}