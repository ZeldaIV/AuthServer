using AuthServer.Data.Models;
using HotChocolate.Types;

namespace AuthServer.GraphQL.ApiResource.Types.Payloads
{
    public class CreateAuthorizationPayload
    {
        public ApplicationAuthorization Authorization { get; set; }
    }
    
    public class CreateAuthorizationPayloadType: ObjectType<CreateAuthorizationPayload>
    {
        protected override void Configure(IObjectTypeDescriptor<CreateAuthorizationPayload> descriptor)
        {
            descriptor.Name(nameof(CreateAuthorizationPayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Authorization)
                .Type<AuthorizationType>();
        }
    }
}