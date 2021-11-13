using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Client.Types.Payloads
{
    public class CreateClientPayload
    {
        public ClientDto ApplicationClient { get; set; }
    }

    public class CreateClientPayloadType: ObjectType<CreateClientPayload>
    {
        protected override void Configure(IObjectTypeDescriptor<CreateClientPayload> descriptor)
        {
            descriptor.Name(nameof(CreateClientPayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.ApplicationClient)
                .Type<ClientType>();
        }
    }
}