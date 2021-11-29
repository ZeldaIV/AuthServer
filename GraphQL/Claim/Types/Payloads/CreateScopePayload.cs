using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Claim.Types.Payloads
{
    public class CreateClaimPayload
    {
        public ClaimDto Claim { get; set; }
    }

    public class CreateClaimPayloadType : ObjectType<CreateClaimPayload>
    {
        protected override void Configure(IObjectTypeDescriptor<CreateClaimPayload> descriptor)
        {
            descriptor.Name(nameof(CreateClaimPayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(x => x.Claim)
                .Type<ClaimType>();
        }
    }
}