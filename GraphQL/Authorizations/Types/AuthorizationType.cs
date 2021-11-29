using AuthServer.Dtos;
using AuthServer.GraphQL.Client.Types;
using HotChocolate.Types;

namespace AuthServer.GraphQL.ApiResource.Types
{
    public class AuthorizationType : ObjectType<AuthorizationDto>
    {
        protected override void Configure(IObjectTypeDescriptor<AuthorizationDto> descriptor)
        {
            descriptor.Name(nameof(AuthorizationDto));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(x => x.Id).Type<NonNullType<UuidType>>().Description("The Id of the api resource");
            descriptor.Field(x => x.Application).Type<NonNullType<ClientType>>().Description("Is the resource enabled");
            descriptor.Field(x => x.Scopes).Type<NonNullType<ListType<NonNullType<StringType>>>>()
                .Description("The name of the resource");
            descriptor.Field(x => x.Status).Type<NonNullType<StringType>>()
                .Description("The display name used in consent screens");
            descriptor.Field(x => x.Subject).Type<NonNullType<StringType>>()
                .Description("The description of the api resource");
            descriptor.Field(x => x.CreationDate).Type<DateTimeType>()
                .Description("The secrets registered for the resource");
            descriptor.Field(x => x.Type).Type<StringType>().Description("The scopes registered for this resource");
        }
    }
}