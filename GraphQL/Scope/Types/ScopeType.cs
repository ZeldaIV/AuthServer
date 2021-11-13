using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Scope.Types
{
    public class ScopeType : ObjectType<ScopeDto>
    {
        protected override void Configure(IObjectTypeDescriptor<ScopeDto> descriptor)
        {
            descriptor.Name(nameof(ScopeDto));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.Name).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.DisplayName).Type<NonNullType<StringType>>().Description("");
        }
    }
}