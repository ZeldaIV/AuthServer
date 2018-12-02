


using System.ComponentModel.DataAnnotations;
using System.Security;
using System.Threading.Tasks;
using AuthServer.Configuration;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace AuthServer.Pages.Account {
    [SecurityHeaders]
    [AllowAnonymous]
    public class LoginModel : PageModel {

        private SignInManager<IdentityUser> _signInManager;
        private ILogger<LoginModel> _logger;

        public LoginModel(SignInManager<IdentityUser> signInManager, ILogger<LoginModel> logger) {
            this._signInManager = signInManager;
            this._logger = logger;
        }

        [BindProperty]
        public InputModel Input { get; set; }

        public string ReturnUrl { get; set; }

        [TempData]
        public string ErrorMessage { get; set; }

        public class InputModel {
            [Required]
            // [EmailAddress]
            public string Username { get; set; }

            [Required]
            [DataType(DataType.Password)]
            public string Password { get; set; }

            [Display(Name = "Remember me?")]
            public bool RememberLogin { get; set; }
        }

        public async Task OnGetAsync(string returnUrl=null) {
            if (!string.IsNullOrEmpty(ErrorMessage)) {
                ModelState.AddModelError(string.Empty, ErrorMessage);
            }

            await HttpContext.SignOutAsync(IdentityConstants.ApplicationScheme);
            ReturnUrl = returnUrl;
        }

        public async Task<IActionResult> OnPostAsync(string returnUrl=null) {
            ReturnUrl = returnUrl;

            if (ModelState.IsValid) {
                var result = await _signInManager.PasswordSignInAsync(Input.Username, Input.Password, Input.RememberLogin, lockoutOnFailure: true);
                if (result.Succeeded) {
                    if (Url.IsLocalUrl(returnUrl)) {
                        return LocalRedirect(returnUrl);
                    } else {
                        return Redirect(returnUrl);
                    }
                } 
                if (result.IsLockedOut) {
                    _logger.LogWarning("User account locked out.");
                    return RedirectToPage("./Lockout");
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Invalid login attempt");
                    return Page();
                }
            }
            return Page();
            
        }
    }
}