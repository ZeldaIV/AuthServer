using System.Threading;
using AuthServer.GraphQL.EmailServer.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.EmailServer;

public class EmailServerTypeQueryExtension: ObjectTypeExtension<EmailServerQuery>
{
    protected override void Configure(IObjectTypeDescriptor<EmailServerQuery> descriptor)
    {
        descriptor.Name("Query");

        descriptor.Field(q => q.GetEmailServer(default!, new CancellationToken()))
            .Type<CreateEmailServerType>();
    }
}