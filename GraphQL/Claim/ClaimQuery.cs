using System;
using System.Collections.Generic;
using AuthServer.Dtos;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Claim
{
    public class ClaimQuery
    {
        public List<ClaimDto> GetClaims([Service] IClaimsService context)
        {
            return context.GetAll().Adapt<List<ClaimDto>>();
        }

        public ClaimDto GetClaimById(Guid id, [Service] IClaimsService context)
        {
            return context.GetById(id).Adapt<ClaimDto>();
        }
    }
}