using AuthServer.GraphQL.Claim.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Claim
{
    public class ClaimTypeQueryExtension : ObjectTypeExtension<ClaimQuery>
    {
        protected override void Configure(IObjectTypeDescriptor<ClaimQuery> descriptor)
        {
            descriptor.Name("Query");

            descriptor.Field(q => q.GetClaimById(default!, default!))
                .Argument("id", x => x.Type<NonNullType<IntType>>())
                .Type<ClaimType>();

            descriptor.Field(q => q.GetClaims(default!))
                .Type<NonNullType<ListType<NonNullType<ClaimType>>>>();
        }
    }
}