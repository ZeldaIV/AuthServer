using System;
using System.Collections.Generic;
using System.Linq;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.ApiResource
{
    public class AuthorizationQuery
    {
        public List<AuthorizationDto> GetAuthorization([Service] IApplicationAuthorizationService context)
        {
            return context.GetAll().ToList().Adapt<List<AuthorizationDto>>();
        }

        // [Authorize(Policy = "Administrator")]
        public AuthorizationDto GetAuthorizationById(Guid id, [Service] IApplicationAuthorizationService context)
        {
            return context.GetById(id).Adapt<AuthorizationDto>();
        }

        // [Authorize(Policy = "Administrator")]
        // public async Task AddResource([Service] IIdentityServerDbContext context, ApiResourceDto resource, CancellationToken cancellationToken)
        // {
        //     await context.AddApiResourceAsync(resource.Adapt<ApiResource>(), cancellationToken);
        // }
        //
        // // [Authorize(Policy = "Administrator")]
        // public async Task UpdateResource([Service] IIdentityServerDbContext context, ApiResourceDto resource, CancellationToken cancellationToken)
        // {
        //     await context.UpdateApiResourceAsync(resource.Adapt<ApiResource>(), cancellationToken);
        // }
    }
}