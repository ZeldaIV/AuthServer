using System.Threading;
using AuthServer.Dtos;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.User.Types.Inputs;
using AuthServer.GraphQL.User.Types.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User
{
    public class UserMutationTypeExtension : ObjectTypeExtension<UserMutation>
    {
        protected override void Configure(IObjectTypeDescriptor<UserMutation> descriptor)
        {
            descriptor.Name("Mutation");

            descriptor.Field(o => o.CreateUserAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<UserInputType>>())
                .Type<NonNullType<CreateUserPayloadType>>();

            descriptor.Field(o => o.DeleteUserAsync(default!, default!, new CancellationToken()))
                .Argument("id", x => x.Type<NonNullType<UuidType>>())
                .Type<NonNullType<DeleteEntityPayloadType>>();

            descriptor.Field(o => o.AddClaimsToUser(default!, default!))
                .Argument("ClaimsInput", x => x.Type<NonNullType<UserClaimsInputType>>())
                .Type<NonNullType<AddRemoveClaimsPayloadType>>();

            descriptor.Field(o => o.RemoveClaimFromUser(default!, default!, default!, new CancellationToken()))
                .Type<NonNullType<AddRemoveClaimsPayloadType>>();
        }
    }
}