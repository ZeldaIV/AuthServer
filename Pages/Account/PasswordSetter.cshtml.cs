using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Account
{
    public class PasswordSetterModel : PageModel
    {
        private readonly ILogger<PasswordSetterModel> _logger;
        private readonly UserManager<IdentityUser> _userManager;

        public PasswordSetterModel(
            ILogger<PasswordSetterModel> logger,
            UserManager<IdentityUser> userManager)
        {
            _logger = logger;
            _userManager = userManager;
        }

        [BindProperty] public InputModel Input { get; set; }

        [TempData] public string Token { get; set; }

        [TempData] public string Username { get; set; }

        public async Task OnGetAsync(string userId, string token)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user != null)
            {
                Username = user.UserName;
                Token = token;
                // Input.Username = user.UserName;
                // Input.Token = token;
                _logger.LogInformation($"User: {user} has been confirmed, allow to set Password");
            }
            else
            {
                ModelState.AddModelError("", "An unknown error occured");
            }
        }

        public async Task<IActionResult> OnPostSetPasswordAsync()
        {
            var user = await _userManager.FindByNameAsync(Username);
            var result = await _userManager.ResetPasswordAsync(user, Token, Input.Password);
            if (result.Succeeded)
                _logger.LogInformation("Password successfully set");
            else
                _logger.LogInformation("Password could not be set");

            return Redirect("/");
        }

        public class InputModel
        {
            [Required]
            [DataType(DataType.Password)]
            public string Password { get; set; }

            [DataType(DataType.Password)]
            [Display(Name = "Confirm password")]
            [Compare("Password", ErrorMessage = "The password and confirmation password do not match.")]
            public string ConfirmPassword { get; set; }
        }
    }
}