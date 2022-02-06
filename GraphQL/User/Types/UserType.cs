using System.Collections.Generic;
using AuthServer.Data.Models;
using AuthServer.Dtos;
using AuthServer.GraphQL.Claim.Types;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate.Types;
using Mapster;

namespace AuthServer.GraphQL.User.Types
{
    public class UserType : ObjectType<UserDto>
    {
        protected override void Configure(IObjectTypeDescriptor<UserDto> descriptor)
        {
            descriptor.Name(nameof(UserDto));

            descriptor.BindFieldsExplicitly();

            descriptor.Field(o => o.Id).Type<NonNullType<UuidType>>();
            descriptor.Field(o => o.UserName).Type<NonNullType<StringType>>().Description("UserName");
            descriptor.Field(o => o.Email).Type<NonNullType<StringType>>().Description("Email");
            descriptor.Field(o => o.EmailConfirmed).Type<NonNullType<BooleanType>>().Description("Confirmed E-mail");
            descriptor.Field(o => o.PhoneNumber).Type<StringType>().Description("Phone number");
            descriptor.Field(o => o.PhoneNumberConfirmed).Type<NonNullType<BooleanType>>()
                .Description("Phone number confirmed");
            descriptor.Field(o => o.TwoFactorEnabled).Type<NonNullType<BooleanType>>()
                .Description("Two factor enabled");
            descriptor.Field(o => o.Claims)
                .Type<NonNullType<ListType<NonNullType<UserClaimType>>>>()
                .Description("Claims associated with the user")
                .Resolve(async (ctx, ct) =>
                {
                    var result = await ctx.Service<IUserService>().GetUserClaims(ctx.Parent<UserDto>().Id, ct);
                    return result.Adapt<List<UserClaimDto>>();
                });

        }
    }
}