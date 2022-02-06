using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.EmailServer.Types.Payloads;

public class EmailServerPayload
{
    public EmailServerDto EmailServer { get; set; }
}

public class EmailServerPayloadType : ObjectType<EmailServerPayload>
{
    protected override void Configure(IObjectTypeDescriptor<EmailServerPayload> descriptor)
    {
        descriptor.Name(nameof(EmailServerPayload));

        descriptor.BindFieldsExplicitly();

        descriptor.Field(o => o.EmailServer)
            .Type<CreateEmailServerType>();
    }
}
