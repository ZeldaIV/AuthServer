using System;
using System.Collections.Generic;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Client.Types.Inputs
{
    public class ClientInput
    {
        public Guid Id { get; set; }
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
        public string DisplayName { get; set; }
        public List<string> DisplayNames { get; set; }
        public List<string> Permissions { get; set; }
        public List<string> PostLogoutRedirectUris { get; set; }
        public List<string> RedirectUris { get; set; }
        public string Type { get; set; }
        public bool RequirePkce { get; set; }
        public bool RequireConsent { get; set; }
    }

    public class ClientInputType : InputObjectType<ClientInput>
    {
        protected override void Configure(IInputObjectTypeDescriptor<ClientInput> descriptor)
        {
            descriptor.Name(nameof(ClientInput));

            descriptor.BindFieldsExplicitly();
            
            descriptor.Field(o => o.ClientId).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.ClientSecret).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.DisplayName).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.Permissions).Type<ListType<NonNullType<StringType>>>().Description("");
            descriptor.Field(o => o.PostLogoutRedirectUris).Type<ListType<NonNullType<StringType>>>().Description("");
            descriptor.Field(o => o.RedirectUris).Type<ListType<NonNullType<StringType>>>().Description("");
            descriptor.Field(o => o.Type).Type<StringType>().Description("");
            descriptor.Field(o => o.RequirePkce).Type<NonNullType<BooleanType>>().Description("");
            descriptor.Field(o => o.RequireConsent).Type<NonNullType<BooleanType>>().Description("");
        }
    }
}