using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User.Types
{
    public class UserClaimType: ObjectType<UserClaimDto>
    {
        protected override void Configure(IObjectTypeDescriptor<UserClaimDto> descriptor)
        {
            descriptor.Name(nameof(UserClaimDto));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Type).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.Value).Type<NonNullType<StringType>>();

        }
    }
    
}