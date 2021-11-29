using System.Threading;
using AuthServer.GraphQL.Client.Types.Inputs;
using AuthServer.GraphQL.Client.Types.Payloads;
using AuthServer.GraphQL.Common.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Client
{
    public class ClientMutationTypeExtension : ObjectTypeExtension<ClientMutation>
    {
        protected override void Configure(IObjectTypeDescriptor<ClientMutation> descriptor)
        {
            descriptor.Name("Mutation");

            descriptor.Field(o => o.CreateClientAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<ClientInputType>>())
                .Type<NonNullType<CreateClientPayloadType>>();

            descriptor.Field(o => o.UpdateClientAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<ClientInputType>>())
                .Type<NonNullType<CreateClientPayloadType>>();

            descriptor.Field(o => o.DeleteClientAsync(default!, default!, new CancellationToken()))
                .Argument("id", x => x.Type<NonNullType<IntType>>())
                .Type<NonNullType<DeleteEntityPayloadType>>();
        }
    }
}