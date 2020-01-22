using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Authserver.Pages.Admin
{
    public class UserAdministrationModel : PageModel
    {
        private readonly ILogger<UserAdministrationModel> _logger;
        private readonly UserManager<IdentityUser> _userManager;

        public UserAdministrationModel(ILogger<UserAdministrationModel> logger, UserManager<IdentityUser> userManager)
        {
            _logger = logger;
            _userManager = userManager;
        }

        [BindProperty] public List<IdentityUser> Users { get; set; }

        [BindProperty] public InputModel Input { get; set; }

        public string Message { get; set; }
        public string CallBackLink { get; set; }

        public async Task OnGetAsync()
        {
            Users = await _userManager.Users.ToListAsync();
        }

        public async Task<IActionResult> OnPostCreate()
        {
            if (ModelState.IsValid)
            {
                var user = new IdentityUser
                {
                    UserName = Input.Username,
                    Email = Input.Username
                };
                var exisitingUser = await _userManager.FindByEmailAsync(Input.Username);
                if (exisitingUser != null)
                {
                    Message = $"The user {user} already exists";
                }
                else
                {
                    var result = await _userManager.CreateAsync(user);
                    if (result.Succeeded)
                    {
                        var code = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                        var callbackUrl = Url.Page("/Account/EmailConfirmation", "ConfirmEmail",
                            new {userId = user.Id, code}, "https");
                        // var callbackUrl = Url.Action(
                        //                         "ConfirmEmail", "Account", 
                        //                         new { userId = user.Id, code = code  }, 
                        //                         protocol: "https");
                        _logger.LogInformation($"User token: {code}");
                        Message = $"User {user} sucessfully created, click the link to set a password";
                        CallBackLink = callbackUrl;
                    }
                }
            }

            Users = await _userManager.Users.ToListAsync();
            return Page();
        }

        public class InputModel
        {
            [Required] [EmailAddress] public string Username { get; set; }
        }
    }
}