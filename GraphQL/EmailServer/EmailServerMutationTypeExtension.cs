using System.Threading;
using AuthServer.GraphQL.EmailServer.Types.Inputs;
using AuthServer.GraphQL.EmailServer.Types.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.EmailServer;

public class EmailServerMutationTypeExtension : ObjectTypeExtension<EmailServerMutation>
{
    protected override void Configure(IObjectTypeDescriptor<EmailServerMutation> descriptor)
    {
        descriptor.Name("Mutation");

        descriptor.Field(o => o.CreateEmailServerAsync(default!, default!, new CancellationToken()))
            .Argument("input", x => x.Type<NonNullType<CreateEmailServerInputType>>())
            .Type<NonNullType<EmailServerPayloadType>>();
        
        descriptor.Field(o => o.UpdateEmailServerAsync(default!, default!, new CancellationToken()))
            .Argument("input", x => x.Type<NonNullType<UpdateEmailServerInputType>>())
            .Type<NonNullType<EmailServerPayloadType>>();
    }
}