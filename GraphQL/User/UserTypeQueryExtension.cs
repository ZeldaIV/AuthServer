using AuthServer.GraphQL.User.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User
{
    public class UserTypeQueryExtension : ObjectTypeExtension<UserQuery>
    {
        protected override void Configure(IObjectTypeDescriptor<UserQuery> descriptor)
        {
            descriptor.Name("Query");

            descriptor.Field(q => q.GetUserById(default!, default!))
                .Argument("id", x => x.Type<NonNullType<StringType>>())
                .Type<UserType>();

            descriptor.Field(q => q.GetUsers(default!))
                .Type<NonNullType<ListType<NonNullType<UserType>>>>();
        }
    }
}