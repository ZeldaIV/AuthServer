using System;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.GraphQL.ApiResource.Types.Inputs;
using AuthServer.GraphQL.ApiResource.Types.Payloads;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;
using Mapster;
using OpenIddict.Abstractions;

namespace AuthServer.GraphQL.ApiResource
{
    public class AuthorizationMutation
    {
        public async Task<CreateAuthorizationPayload> CreateAuthorizationAsync(
            [Service] IOpenIddictApplicationStore<ApplicationAuthorization> service, AuthorizationInput input,
            CancellationToken cancellationToken)
        {
            var apiResource = input.Adapt<ApplicationAuthorization>();

            await service.CreateAsync(apiResource, cancellationToken);

            return new CreateAuthorizationPayload
            {
                Authorization = apiResource
            };
        }

        public async Task<DeleteEntityByIdPayload> DeleteAuthorizationAsync(
            [Service] IApplicationAuthorizationService service, Guid id, CancellationToken cancellationToken)
        {
            return new DeleteEntityByIdPayload
            {
                Success = await service.DeleteByIdAsync(id, cancellationToken)
            };
        }
    }
}