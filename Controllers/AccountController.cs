using System;
using System.Threading.Tasks;
using AuthServer.Dtos;
using AuthServer.Utilities;
using IdentityServer4.Events;
using IdentityServer4.Extensions;
using IdentityServer4.Models;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Serilog;

namespace AuthServer.Controllers
{
    [AllowAnonymous]
    public class AccountController: ControllerBase
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly SignInManager<IdentityUser> _signInManager;
        private readonly IAuthenticationSchemeProvider _schemeProvider;

        public AccountController(
            UserManager<IdentityUser> userManager,
            SignInManager<IdentityUser> signInManager,
            IAuthenticationSchemeProvider schemeProvider,
            IControllerUtils utils
            ): base(utils)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _schemeProvider = schemeProvider;
        }

        public class LoginRequest
        {
            public string Username { get; set; }
            public string Password { get; set; }
            public string ReturnUrl { get; set; }
        }

        [HttpPost]
        // [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login([FromBody]LoginRequest model)
        {
            var t = new IdentityResource();
            var context = await Interaction.GetAuthorizationContextAsync(model.ReturnUrl);
            Log.Information($"===> Found context: {context}");
            // the user clicked the "cancel" button
            // if (button != "login")
            // {
            //     if (context != null)
            //     {
            //         // if the user cancels, send a result back into IdentityServer as if they 
            //         // denied the consent (even if this client does not require consent).
            //         // this will send back an access denied OIDC error response to the client.
            //         await _interaction.GrantConsentAsync(context, ConsentResponse.Denied);
            //
            //         // we can trust model.ReturnUrl since GetAuthorizationContextAsync returned non-null
            //         if (await _clientStore.IsPkceClientAsync(context.ClientId))
            //         {
            //             // if the client is PKCE then we assume it's native, so this change in how to
            //             // return the response is for better UX for the end user.
            //             return View("Redirect", new RedirectViewModel { RedirectUrl = model.ReturnUrl });
            //         }
            //
            //         return Redirect(model.ReturnUrl);
            //     }
            //     else
            //     {
            //         // since we don't have a valid context, then we just go back to the home page
            //         return Redirect("~/");
            //     }
            // }

            var result = await _signInManager.PasswordSignInAsync(model.Username, model.Password, false, lockoutOnFailure: true);
            if (result.Succeeded)
            {
                Log.Information($"===> Successfull login");
                var user = await _userManager.FindByNameAsync(model.Username);
                await Events.RaiseAsync(new UserLoginSuccessEvent(user.UserName, user.Id, user.UserName, clientId: context?.Client.ClientId));
                if (context != null)
                {
                //    if (await _clientStore.IsPkceClientAsync(context.ClientId))
                //    {
                        // if the client is PKCE then we assume it's native, so this change in how to
                        // return the response is for better UX for the end user.
                //        return View("Redirect", new RedirectViewModel { RedirectUrl = model.ReturnUrl });
                //    }

                    // we can trust model.ReturnUrl since GetAuthorizationContextAsync returned non-null
                return Redirect(model.ReturnUrl);
                }

                // request for a local page
                if (Url.IsLocalUrl(model.ReturnUrl))
                {
                    Log.Information($"==========> redirecting local: {model.ReturnUrl}");
                    return new OkResult();
                }
                if (string.IsNullOrEmpty(model.ReturnUrl))
                {
                    Log.Information($"==========> Is null or empty: {model.ReturnUrl}");
                    return new OkResult();
                    //return Redirect("~/");
                }
                
                // user might have clicked on a malicious link - should be logged
                throw new Exception("invalid return URL");
                
            }

            await Events.RaiseAsync(new UserLoginFailureEvent(model.Username, "invalid credentials", clientId:context?.Client.ClientId));
            // ModelState.AddModelError(string.Empty, AccountOptions.InvalidCredentialsErrorMessage);

            
            return Unauthorized();
        }

        public class LogoutInputModel
        {
            public string LogoutId { get; set; }
        }
        
        [HttpPost]
        [Route("logout")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout(LogoutInputModel model)
        {
            if (User?.Identity.IsAuthenticated == true)
            {
                // delete local authentication cookie
                await _signInManager.SignOutAsync();

                // raise the logout event
                await Events.RaiseAsync(new UserLogoutSuccessEvent(User.GetSubjectId(), User.GetDisplayName()));
            }


            return Redirect("~/");
        }

        [HttpGet]
        [Route("user")]
        [Authorize(Policy = "Administrator")]
        // [ValidateAntiForgeryToken]
        public UserDto GetUser()
        {
            return User?.Identity?.IsAuthenticated == true ? new UserDto { UserName = User.Identity.Name } : null;
        }

        [HttpGet]
        [Route("isSignedIn")]
        public bool IsSignedIn()
        {
            return User?.Identity?.IsAuthenticated ?? false;
        }
        

        
    }
    
}