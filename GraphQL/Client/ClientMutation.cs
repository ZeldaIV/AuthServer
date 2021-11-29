using System;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using AuthServer.GraphQL.Client.Types.Inputs;
using AuthServer.GraphQL.Client.Types.Payloads;
using AuthServer.GraphQL.Common.Payloads;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Client
{
    public class ClientMutation
    {
        public async Task<CreateClientPayload> CreateClientAsync([Service] IClientService service, ClientInput input,
            CancellationToken cancellationToken)
        {
            var client = input.Adapt<ApplicationClient>();
            client.Id = input.ClientId;

            await service.CreateAsync(client, cancellationToken);

            return new CreateClientPayload
            {
                ApplicationClient = client.Adapt<ClientDto>()
            };
        }

        public async Task<CreateClientPayload> UpdateClientAsync([Service] IClientService service, ClientInput input,
            CancellationToken cancellationToken)
        {
            var client = input.Adapt<ApplicationClient>();
            client.Id = input.ClientId;

            await service.UpdateAsync(client, cancellationToken);

            return new CreateClientPayload
            {
                ApplicationClient = client.Adapt<ClientDto>()
            };
        }

        public async Task<DeleteEntityByIdPayload> DeleteClientAsync([Service] IClientService service, Guid id,
            CancellationToken cancellationToken)
        {
            return new DeleteEntityByIdPayload
            {
                Success = await service.DeleteByIdAsync(id, cancellationToken)
            };
        }
    }
}