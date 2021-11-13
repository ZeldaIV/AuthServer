using System.Threading;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.User.Types.Inputs;
using AuthServer.GraphQL.User.Types.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User
{
    public class UserMutationTypeExtension: ObjectTypeExtension<UserMutation>
    {
        protected override void Configure(IObjectTypeDescriptor<UserMutation> descriptor)
        {
            descriptor.Name("Mutation");

            descriptor.Field(o => o.CreateUserAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<UserInputType>>())
                .Type<NonNullType<CreateUserPayloadType>>();

            descriptor.Field(o => o.DeleteUserAsync(default!, default!, new CancellationToken()))
                .Argument("id", x => x.Type<NonNullType<StringType>>())
                .Type<NonNullType<DeleteEntityPayloadType>>();

        }
    }
}