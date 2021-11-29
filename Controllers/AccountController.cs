using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.Dtos;
using AuthServer.Utilities;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using OpenIddict.Server.AspNetCore;

namespace AuthServer.Controllers
{
    [AllowAnonymous]
    public class AccountController : ApiBaseController
    {
        private readonly IAuthenticationSchemeProvider _schemeProvider;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly UserManager<ApplicationUser> _userManager;

        public AccountController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IAuthenticationSchemeProvider schemeProvider,
            IControllerUtils utils
        ) : base(utils)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _schemeProvider = schemeProvider;
        }

        [HttpPost]
        [AllowAnonymous]
        // [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login([FromBody] LoginRequest model)
        {
            var result = await _signInManager.PasswordSignInAsync(model.Username, model.Password, false, true);
            if (!result.Succeeded)
                return Unauthorized();

            var claims = new List<Claim>
            {
                new(ClaimTypes.Name, model.Username)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            await HttpContext.SignInAsync(new ClaimsPrincipal(claimsIdentity));

            // request for a local page
            if (Url.IsLocalUrl(model.ReturnUrl)) return Redirect(model.ReturnUrl);
            if (string.IsNullOrEmpty(model.ReturnUrl))
                // Login succeeded, and we are local
                return new OkResult();

            // user might have clicked on a malicious link - should be logged
            throw new Exception("invalid return URL");
        }

        [HttpPost]
        [Route("logout")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout(LogoutInputModel model)
        {
            if (User.Identity?.IsAuthenticated != true) return Redirect("~/");
            // delete local authentication cookie

            await _signInManager.SignOutAsync();

            // Returning a SignOutResult will ask OpenIddict to redirect the user agent
            // to the post_logout_redirect_uri specified by the client application or to
            // the RedirectUri specified in the authentication properties if none was set.
            return SignOut(
                authenticationSchemes: OpenIddictServerAspNetCoreDefaults.AuthenticationScheme,
                properties: new AuthenticationProperties
                {
                    RedirectUri = "/login"
                });
        }

        [HttpGet]
        [Route("user")]
        [Authorize(Policy = "Administrator")]
        // [ValidateAntiForgeryToken]
        public UserDto GetUser()
        {
            return User.Identity?.IsAuthenticated == true ? new UserDto { UserName = User.Identity.Name } : null;
        }

        [HttpGet]
        [Route("isSignedIn")]
        public bool IsSignedIn()
        {
            return User.Identity?.IsAuthenticated ?? false;
        }

        public class LoginRequest
        {
            public string Username { get; set; }
            public string Password { get; set; }
            public string ReturnUrl { get; set; }
        }

        public class LogoutInputModel
        {
            public string LogoutId { get; set; }
        }
    }
}