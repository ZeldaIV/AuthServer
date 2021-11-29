using AuthServer.GraphQL.Client.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Client
{
    public class ClientTypeQueryExtension : ObjectTypeExtension<ClientQuery>
    {
        protected override void Configure(IObjectTypeDescriptor<ClientQuery> descriptor)
        {
            descriptor.Name("Query");

            descriptor.Field(q => q.GetClients(default!))
                .Type<NonNullType<ListType<NonNullType<ClientType>>>>();

            descriptor.Field(q => q.GetClientById(default!, default!))
                .Argument("id", x => x.Type<NonNullType<UuidType>>())
                .Type<ClientType>();
        }
    }
}