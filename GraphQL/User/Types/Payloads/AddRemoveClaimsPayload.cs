using HotChocolate.Types;

namespace AuthServer.GraphQL.User.Types.Payloads
{
    public class AddRemoveClaimsPayload
    {
        public bool Success { get; set; }
    }
    
    public class AddRemoveClaimsPayloadType : ObjectType<AddRemoveClaimsPayload>
    {
        protected override void Configure(IObjectTypeDescriptor<AddRemoveClaimsPayload> descriptor)
        {
            descriptor.Name(nameof(AddRemoveClaimsPayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(x => x.Success)
                .Type<NonNullType<BooleanType>>();
        }
    }
}