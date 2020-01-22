using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;

namespace AuthServer.Authorization
{
    public class AdministratorHandler : AuthorizationHandler<AdministratorRequirement>
    {
        private readonly ILogger<AdministratorHandler> _logger;

        public AdministratorHandler(ILogger<AdministratorHandler> logger)
        {
            _logger = logger;
        }

        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context,
            AdministratorRequirement requirement)
        {
            var pendingRequirements = context.PendingRequirements.ToList();
            // && c.Issuer == "https://authserver.com"
            if (!context.User.HasClaim(c => c.Type == ClaimTypes.Role))
            {
                _logger.LogInformation("Claim Role not found");
                return Task.CompletedTask;
            }

            var roleValue = context.User.FindFirst(c => c.Type == ClaimTypes.Role).Value;

            if (roleValue == requirement.Role)
            {
                _logger.LogInformation("Claim found. Allowing");
                context.Succeed(requirement);
            }

            return Task.CompletedTask;
        }
    }
}