using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Scope.Types.Payloads
{
    public class CreateScopePayload
    {
        public ScopeDto Scope { get; set; }
    }

    public class CreateScopePayloadType : ObjectType<CreateScopePayload>
    {
        protected override void Configure(IObjectTypeDescriptor<CreateScopePayload> descriptor)
        {
            descriptor.Name(nameof(CreateScopePayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(x => x.Scope)
                .Type<ScopeType>();
        }
    }
}