using System.Collections.Generic;
using AuthServer.Dtos;
using AuthServer.Utilities;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    public class UsersController: ControllerBase
    {
        protected UsersController(IControllerUtils utils) : base(utils)
        {
        }

        [HttpGet]
        // [Authorize(Policy = "Administrator")]
        public List<UserDto> GetUsers()
        {
            return new List<UserDto>();
        }

        [HttpPut]
        // [Authorize(Policy = "Administrator")]
        public bool AddUser(UserDto user)
        {
            return true;
        }
    }
}