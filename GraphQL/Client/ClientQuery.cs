using System;
using System.Collections.Generic;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Client
{
    public class ClientQuery
    {
        public List<ClientDto> GetClients([Service] IClientService context)
        {
            return context.GetAllClients().Adapt<List<ClientDto>>();
        }

        public ClientDto GetClientById(Guid id, [Service] IClientService context)
        {
            var clientById = context.GetClientById(id).Adapt<ClientDto>();
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