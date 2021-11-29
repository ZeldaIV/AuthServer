using System.Threading;
using AuthServer.GraphQL.ApiResource.Types.Inputs;
using AuthServer.GraphQL.ApiResource.Types.Payloads;
using AuthServer.GraphQL.Common.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.ApiResource
{
    public class AuthorizationMutationTypeExtension : ObjectTypeExtension<AuthorizationMutation>
    {
        protected override void Configure(IObjectTypeDescriptor<AuthorizationMutation> descriptor)
        {
            descriptor.Name("Mutation");

            descriptor.Field(o => o.CreateAuthorizationAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<AuthorizationInputType>>())
                .Type<NonNullType<CreateAuthorizationPayloadType>>();

            descriptor.Field(o => o.DeleteAuthorizationAsync(default!, default!, new CancellationToken()))
                .Argument("id", x => x.Type<NonNullType<IntType>>())
                .Type<NonNullType<DeleteEntityPayloadType>>();
        }
    }
}