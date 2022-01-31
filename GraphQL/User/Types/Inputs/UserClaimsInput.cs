using System;
using System.Collections.Generic;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User.Types.Inputs
{
    public class UserClaimsInput
    {
        public Guid UserId { get; set; }
        public List<Guid> ClaimIds { get; set; }
    }
    
    public class UserClaimsInputType : InputObjectType<UserClaimsInput>
    {
        protected override void Configure(IInputObjectTypeDescriptor<UserClaimsInput> descriptor)
        {
            descriptor.Name(nameof(UserClaimsInput));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.UserId).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.ClaimIds).Type<NonNullType<ListType<NonNullType<UuidType>>>>();
        }
    }
}