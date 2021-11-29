using HotChocolate.Types;

namespace AuthServer.GraphQL.Common.Payloads
{
    public class DeleteEntityByIdPayload
    {
        public bool Success { get; set; }
    }

    public class DeleteEntityPayloadType : ObjectType<DeleteEntityByIdPayload>
    {
        protected override void Configure(IObjectTypeDescriptor<DeleteEntityByIdPayload> descriptor)
        {
            descriptor.Name(nameof(DeleteEntityByIdPayload));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Success)
                .Type<NonNullType<BooleanType>>();
        }
    }
}