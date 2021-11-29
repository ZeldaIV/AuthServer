using System;
using System.Collections.Generic;
using AuthServer.Dtos;
using AuthServer.GraphQL.Client.Types.Inputs;
using HotChocolate.Types;

namespace AuthServer.GraphQL.ApiResource.Types.Inputs
{
    public class AuthorizationInput
    {
        public Guid Id { get; set; }
        public ClientDto Application { get; set; }
        public List<string> Scopes { get; set; }
        public string Status { get; set; }
        public string Subject { get; set; }
        public DateTime? CreationDate { get; set; }
        public string Type { get; set; }
    }

    public class AuthorizationInputType : InputObjectType<AuthorizationInput>
    {
        protected override void Configure(IInputObjectTypeDescriptor<AuthorizationInput> descriptor)
        {
            descriptor.Name(nameof(AuthorizationInput));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.Application).Type<ClientInputType>();
            descriptor.Field(o => o.Scopes).Type<NonNullType<ListType<StringType>>>();
            descriptor.Field(o => o.Status).Type<StringType>();
            descriptor.Field(o => o.Subject).Type<NonNullType<ListType<NonNullType<StringType>>>>();
            descriptor.Field(o => o.CreationDate).Type<NonNullType<ListType<NonNullType<StringType>>>>();
            descriptor.Field(o => o.Type).Type<NonNullType<StringType>>();
        }
    }
}