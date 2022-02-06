using System;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.User.Types.Inputs;
using AuthServer.GraphQL.User.Types.Payloads;
using AuthServer.Services.DbServices.Interfaces;
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

            await context.CreateAsync(user, cancellationToken);

            return new CreateUserPayload
            {
                User = user
            };
        }

        public async Task<AddRemoveClaimsPayload> AddClaimsToUser([Service] IUserService context, UserClaimsInput input)
        {
            return new AddRemoveClaimsPayload
            {
                Success = await context.AddUserClaims(input.UserId, input.ClaimIds)
            };
        }
        
        public async Task<bool> RemoveClaimFromUser([Service] IUserService context, Guid userId, [GraphQLNonNullType] string claimType,
            CancellationToken cancellationToken)
        {
            return await context.RemoveClaimFromUser(userId, claimType, cancellationToken);
        }

        public async Task<DeleteEntityByIdPayload> DeleteUserAsync([Service] IUserService service, Guid id,
            CancellationToken cancellationToken)
        {
            return new DeleteEntityByIdPayload
            {
                Success = await service.DeleteByIdAsync(id, cancellationToken)
            };
        }
    }
}