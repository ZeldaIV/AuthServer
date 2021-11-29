using System.Threading;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.Claim.Types.Inputs;
using AuthServer.GraphQL.Claim.Types.Payloads;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Claim
{
    public class ClaimMutationTypeExtension : ObjectTypeExtension<ClaimMutation>
    {
        protected override void Configure(IObjectTypeDescriptor<ClaimMutation> descriptor)
        {
            descriptor.Name("Mutation");

            descriptor.Field(o => o.CreateClaimAsync(default!, default!, new CancellationToken()))
                .Argument("input", x => x.Type<NonNullType<ClaimInputType>>())
                .Type<NonNullType<CreateClaimPayloadType>>();

            descriptor.Field(o => o.DeleteClaimAsync(default!, default!, new CancellationToken()))
                .Argument("id", x => x.Type<NonNullType<UuidType>>())
                .Type<NonNullType<DeleteEntityPayloadType>>();
        }
    }
}