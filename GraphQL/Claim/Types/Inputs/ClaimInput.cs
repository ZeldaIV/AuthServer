using System;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Claim.Types.Inputs
{
    public class ClaimInput
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Value { get; set; }
    }

    public class ClaimInputType : InputObjectType<ClaimInput>
    {
        protected override void Configure(IInputObjectTypeDescriptor<ClaimInput> descriptor)
        {
            descriptor.Name(nameof(ClaimInput));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.Name).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.Description).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.Value).Type<NonNullType<StringType>>();
        }
    }
}