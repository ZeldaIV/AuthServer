using HotChocolate.Types;

namespace AuthServer.GraphQL.EmailServer.Types.Inputs;

public class UpdateEmailServerInput
{
    public string Host { get; set; }
    public int Port { get; set; }
    public string UserName { get; set; }
    public string FromAddress { get; set; }
    public string FromDisplayName { get; set; }
}

public class UpdateEmailServerInputType : InputObjectType<UpdateEmailServerInput>
{
    protected override void Configure(IInputObjectTypeDescriptor<UpdateEmailServerInput> descriptor)
    {
        descriptor.Name(nameof(UpdateEmailServerInput));

        descriptor.Field(o => o.Host).Type<StringType>();
        descriptor.Field(o => o.Port).Type<PortType>();
        descriptor.Field(o => o.UserName).Type<StringType>();
        descriptor.Field(o => o.FromAddress).Type<EmailAddressType>();
        descriptor.Field(o => o.FromDisplayName).Type<StringType>();
    }
}