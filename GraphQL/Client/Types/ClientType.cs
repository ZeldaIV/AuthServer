using AuthServer.Dtos;
using HotChocolate.Types;

namespace AuthServer.GraphQL.Client.Types
{
    public class ClientType : ObjectType<ClientDto>
    {
        protected override void Configure(IObjectTypeDescriptor<ClientDto> descriptor)
        {
            descriptor.Name(nameof(ClientDto));

            descriptor.BindFieldsExplicitly();


            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>().Description("");
            descriptor.Field(o => o.ClientId).Type<NonNullType<UuidType>>().Description("");
            descriptor.Field(o => o.ClientSecret).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.DisplayName).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.DisplayNames).Type<NonNullType<ListType<NonNullType<StringType>>>>().Description("");
            descriptor.Field(o => o.Permissions).Type<NonNullType<ListType<NonNullType<StringType>>>>().Description("");
            descriptor.Field(o => o.PostLogoutRedirectUris).Type<NonNullType<ListType<NonNullType<StringType>>>>().Description("");
            descriptor.Field(o => o.RedirectUris).Type<NonNullType<ListType<NonNullType<StringType>>>>().Description("");
            descriptor.Field(o => o.Type).Type<NonNullType<StringType>>().Description("");
            descriptor.Field(o => o.RequirePkce).Type<NonNullType<BooleanType>>().Description("");
            descriptor.Field(o => o.RequireConsent).Type<NonNullType<BooleanType>>().Description("");
        }
    }
}
