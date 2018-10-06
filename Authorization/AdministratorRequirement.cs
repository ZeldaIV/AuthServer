
using Microsoft.AspNetCore.Authorization;

namespace AuthServer.Authorization {
    public class AdministratorRequirement: IAuthorizationRequirement {
        public readonly string Role = "Administrator";
    }
}