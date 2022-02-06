using System;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.Dtos;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.Scope.Types.Inputs;
using AuthServer.GraphQL.Scope.Types.Payloads;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Scope
{
    public class ScopeMutation
    {
        public async Task<CreateScopePayload> CreateScopeAsync([Service] IScopeService service, ScopeInput input,
            CancellationToken cancellationToken)
        {
            var scope = input.Adapt<ApplicationScope>();

            await service.CreateAsync(scope, cancellationToken);

            return new CreateScopePayload
            {
                Scope = scope.Adapt<ScopeDto>()
            };
        }

        public async Task<DeleteEntityByIdPayload> DeleteScopeAsync([Service] IScopeService service, Guid id,
            CancellationToken cancellationToken)
        {
            return new DeleteEntityByIdPayload
            {
                Success = await service.DeleteByIdAsync(id, cancellationToken)
            };
        }
    }
}