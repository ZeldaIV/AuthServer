using AuthServer.GraphQL.Scope.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Scope
{
    public class ScopeTypeQueryExtension : ObjectTypeExtension<ScopeQuery>
    {
        protected override void Configure(IObjectTypeDescriptor<ScopeQuery> descriptor)
        {
            descriptor.Name("Query");

            descriptor.Field(q => q.GetScopeById(default!, default!))
                .Argument("id", x => x.Type<NonNullType<IntType>>())
                .Type<ScopeType>();

            descriptor.Field(q => q.GetScopes(default!))
                .Type<NonNullType<ListType<NonNullType<ScopeType>>>>();
        }
    }
}