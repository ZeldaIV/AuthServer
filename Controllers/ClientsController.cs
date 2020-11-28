using System.Collections.Generic;
using AuthServer.Dtos;
using AuthServer.Utilities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    public class ClientsController: ControllerBase
    {
        protected ClientsController(IControllerUtils utils) : base(utils)
        {
        }

        [HttpGet]
        [Authorize(Policy = "Administrator")]
        public List<ClientDto> GetClients()
        {
            return new List<ClientDto>();
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public bool AddClient(ClientDto client)
        {
            return true;
        }
    }
}