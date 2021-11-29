using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Claim.Types
{
    public class ClaimType : ObjectType<ClaimDto>
    {
        protected override void Configure(IObjectTypeDescriptor<ClaimDto> descriptor)
        {
            descriptor.Name(nameof(ClaimDto));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.Name).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.Description).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.Value).Type<NonNullType<StringType>>().Description("");
        }
    }
}