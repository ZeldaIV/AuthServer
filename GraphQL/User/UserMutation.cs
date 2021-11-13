using System.Threading;
using System.Threading.Tasks;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.User.Types.Inputs;
using AuthServer.GraphQL.User.Types.Payloads;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.User
{
    public class UserMutation
    {
        public async Task<CreateUserPayload> CreateUserAsync([Service] IUserService context, UserInput input,
            CancellationToken cancellationToken)
        {
            var user = input.Adapt<UserDto>();

            await context.AddUser(user, cancellationToken);

            return new CreateUserPayload
            {
                User = user
            };
        }
        
        public async Task<DeleteEntityByIdPayload> DeleteUserAsync([Service] IUserService service, string id, CancellationToken cancellationToken)
        {
            return new DeleteEntityByIdPayload
            {
                Success = await service.DeleteByIdAsync(id, cancellationToken)
            };
        }
    }
}