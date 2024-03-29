using System;
using System.Collections.Generic;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Scope.Types.Inputs
{
    public class ScopeInput
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string DisplayName { get; set; }
        public string Description { get; set; }
        public List<string> Resources { get; set; }
    }

    public class ScopeInputType : InputObjectType<ScopeInput>
    {
        protected override void Configure(IInputObjectTypeDescriptor<ScopeInput> descriptor)
        {
            descriptor.Name(nameof(ScopeInput));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.Name).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.DisplayName).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.Description).Type<StringType>();
            descriptor.Field(o => o.Resources).Type<ListType<NonNullType<StringType>>>();
        }
    }
}