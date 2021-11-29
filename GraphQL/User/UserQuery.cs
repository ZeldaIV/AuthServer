using System;
using System.Collections.Generic;
using System.Threading;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.User
{
    public class UserQuery
    {
        public List<UserDto> GetUsers([Service] IUserService context)
        {
            return context.GetAll().Adapt<List<UserDto>>();
        }

        public UserDto GetUserById(Guid id, [Service] IUserService context)
        {
            return context.GetById(id);
        }

        public List<ClaimDto> GetUserClaims(Guid id, [Service] IUserService context, CancellationToken cancellationToken)
        {
            return context.GetUserClaims(id, cancellationToken).Adapt<List<ClaimDto>>();
        }
    }
}