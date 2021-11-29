using System;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using AuthServer.GraphQL.Common.Payloads;
using AuthServer.GraphQL.Claim.Types.Inputs;
using AuthServer.GraphQL.Claim.Types.Payloads;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Claim
{
    public class ClaimMutation
    {
        public async Task<CreateClaimPayload> CreateClaimAsync([Service] IClaimsService service, ClaimInput input,
            CancellationToken cancellationToken)
        {
            var claim = input.Adapt<System.Security.Claims.Claim>();

            await service.CreateAsync(claim, cancellationToken);

            return new CreateClaimPayload
            {
                Claim = claim.Adapt<ClaimDto>()
            };
        }

        public async Task<DeleteEntityByIdPayload> DeleteClaimAsync([Service] IClaimsService service, Guid id,
            CancellationToken cancellationToken)
        {
            return new DeleteEntityByIdPayload
            {
                Success = await service.DeleteByIdAsync(id, cancellationToken)
            };
        }
    }
}