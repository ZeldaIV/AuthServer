using System.Threading;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.Scope.Types.Inputs;
using AuthServer.GraphQL.Scope.Types.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Scope
{
    public class ScopeMutationTypeExtension : ObjectTypeExtension<ScopeMutation>
    {
        protected override void Configure(IObjectTypeDescriptor<ScopeMutation> descriptor)
        {
            descriptor.Name("Mutation");

            descriptor.Field(o => o.CreateScopeAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<ScopeInputType>>())
                .Type<NonNullType<CreateScopePayloadType>>();

            descriptor.Field(o => o.DeleteScopeAsync(default!, default!, new CancellationToken()))
                .Argument("id", x => x.Type<NonNullType<UuidType>>())
                .Type<NonNullType<DeleteEntityPayloadType>>();
        }
    }
}