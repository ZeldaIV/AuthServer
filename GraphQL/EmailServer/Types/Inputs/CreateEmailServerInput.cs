using HotChocolate.Types;

namespace AuthServer.GraphQL.EmailServer.Types.Inputs;

public class CreateEmailServerInput
{
    public string Host { get; set; }
    public int Port { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    public string FromAddress { get; set; }
    public string FromDisplayName { get; set; }
}

public class CreateEmailServerInputType : InputObjectType<CreateEmailServerInput>
{
    protected override void Configure(IInputObjectTypeDescriptor<CreateEmailServerInput> descriptor)
    {
        descriptor.Name(nameof(CreateEmailServerInput));

        descriptor.Field(o => o.Host).Type<StringType>();
        descriptor.Field(o => o.Port).Type<PortType>();
        descriptor.Field(o => o.UserName).Type<StringType>();
        descriptor.Field(o => o.Password).Type<StringType>();
        descriptor.Field(o => o.FromAddress).Type<EmailAddressType>();
        descriptor.Field(o => o.FromDisplayName).Type<StringType>();
    }
}