using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.EmailServer.Types;

public class CreateEmailServerType: ObjectType<EmailServerDto>
{
    protected override void Configure(IObjectTypeDescriptor<EmailServerDto> descriptor)
    {
        descriptor.Name(nameof(EmailServerDto));

        descriptor.BindFieldsExplicitly();
        
        descriptor.Field(d => d.Host).Type<StringType>();
        descriptor.Field(d => d.Port).Type<PortType>();
        descriptor.Field(d => d.UserName).Type<StringType>();
        descriptor.Field(d => d.FromAddress).Type<EmailAddressType>();
        descriptor.Field(d => d.FromDisplayName).Type<StringType>();
        
        
    }
}