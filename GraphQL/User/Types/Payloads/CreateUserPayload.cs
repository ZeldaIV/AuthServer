using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User.Types.Payloads
{
    public class CreateUserPayload
    {
        public UserDto User { get; set; }
    }

    public class CreateUserPayloadType : ObjectType<CreateUserPayload>
    {
        protected override void Configure(IObjectTypeDescriptor<CreateUserPayload> descriptor)
        {
            descriptor.Name(nameof(CreateUserPayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.User)
                .Type<UserType>();
        }
    }
}