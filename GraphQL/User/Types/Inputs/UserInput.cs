using System;
using HotChocolate.Types;

namespace AuthServer.GraphQL.User.Types.Inputs
{
    public class UserInput
    {
        public Guid Id { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public bool TwoFactorEnabled { get; set; }
    }
    

    public class UserInputType : InputObjectType<UserInput>
    {
        protected override void Configure(IInputObjectTypeDescriptor<UserInput> descriptor)
        {
            descriptor.Name(nameof(UserInput));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.UserName).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.Email).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.PhoneNumber).Type<NonNullType<StringType>>();
            descriptor.Field(o => o.TwoFactorEnabled).Type<NonNullType<BooleanType>>();
        }
    }
}