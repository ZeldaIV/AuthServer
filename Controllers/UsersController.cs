using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;
using AuthServer.Utilities;
using IdentityServer4.EntityFramework.Entities;
using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    public class UsersController: ControllerBase
    {
        protected UsersController(IControllerUtils utils) : base(utils)
        {
        }

        [HttpGet]
        [Authorize(Policy = "Administrator")]
        public List<UserDto> GetUsers()
        {
            return DbContext.GetUsers().Adapt<List<UserDto>>();
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public async Task<bool> AddUser(UserDto user, CancellationToken cancellationToken)
        {
            await DbContext.AddUser(user.Adapt<IdentityUser>(), cancellationToken);
            return true;
        }
    }
}