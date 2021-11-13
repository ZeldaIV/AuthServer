using System.Collections.Generic;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using HotChocolate;

namespace AuthServer.GraphQL.User
{
    public class UserQuery
    {
        public List<UserDto> GetUsers([Service] IUserService context)
        {
            return context.GetUsers();
        }

        public UserDto GetUserById(string id, [Service] IUserService context)
        {
            return context.GetUserById(id);
        }
    }
}