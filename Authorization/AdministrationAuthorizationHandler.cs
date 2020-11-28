using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Serilog;

namespace AuthServer.Authorization
{
    public class AdministratorHandler : AuthorizationHandler<AdministratorRequirement>
    {

        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context,
            AdministratorRequirement requirement)
        {
            var pendingRequirements = context.PendingRequirements.ToList();
            // && c.Issuer == "https://authserver.com"
            if (!context.User.HasClaim(c => c.Type == ClaimTypes.Role))
            {
                Log.Information("Claim Role not found");
                return Task.CompletedTask;
            }

            var roleValue = context.User.FindFirst(c => c.Type == ClaimTypes.Role).Value;

            if (roleValue == requirement.Role)
            {
                Log.Information("Claim found. Allowing");
                context.Succeed(requirement);
            }

            return Task.CompletedTask;
        }
    }
}