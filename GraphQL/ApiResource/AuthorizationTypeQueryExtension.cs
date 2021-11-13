using AuthServer.GraphQL.ApiResource.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.ApiResource
{
    public class AuthorizationTypeQueryExtension : ObjectTypeExtension<AuthorizationQuery>
    {
        protected override void Configure(IObjectTypeDescriptor<AuthorizationQuery> descriptor)
        {
            descriptor.Name("Query");

            descriptor.Field(q => q.GetAuthorizationById(default!, default!))
                .Argument("id", x => x.Type<NonNullType<UuidType>>())
                .Type<AuthorizationType>();

            descriptor.Field(q => q.GetAuthorization(default!))
                .Type<NonNullType<ListType<NonNullType<AuthorizationType>>>>();
        }
    }
}