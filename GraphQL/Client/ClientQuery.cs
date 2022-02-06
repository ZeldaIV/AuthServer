using System;
using System.Collections.Generic;
using AuthServer.Dtos;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Client
{
    public class ClientQuery
    {
        public List<ClientDto> GetClients([Service] IClientService context)
        {
            return context.GetAll().Adapt<List<ClientDto>>();
        }

        public ClientDto GetClientById(Guid id, [Service] IClientService context)
        {
            var clientById = context.GetById(id).Adapt<ClientDto>();
            return clientById;
        }

        // [Authorize(Policy = "Administrator")]
        // public async Task AddClient([FromBody] ClientDto client, CancellationToken cancellationToken)
        // {
        //     await context.AddClient(client.Adapt<Client>(), cancellationToken);
        // }

        // [Authorize(Policy = "Administrator")]
        // public async Task UpdateClient([FromBody] ClientDto client, CancellationToken cancellationToken)
        // {
        //     await context.UpdateClient(client.Adapt<Client>(), cancellationToken);
        // }
    }
}