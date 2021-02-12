using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Dtos;
using AuthServer.Utilities;
using IdentityServer4.EntityFramework.Entities;
using Mapster;
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
            return DbContext.GetAllClients().Adapt<List<ClientDto>>();
        }

        [HttpPut]
        [Authorize(Policy = "Administrator")]
        public async Task AddClient([FromBody] ClientDto client, CancellationToken cancellationToken)
        {
            await DbContext.AddClient(client.Adapt<Client>(), cancellationToken);
        }

        [HttpPatch]
        [Authorize(Policy = "Administrator")]
        public async Task UpdateClean([FromBody] ClientDto client, CancellationToken cancellationToken)
        {
            await DbContext.UpdateClient(client.Adapt<Client>(), cancellationToken);
        }
    }
}