using System;
using System.Collections.Generic;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Scope
{
    public class ScopeQuery
    {
        public List<ScopeDto> GetScopes([Service] IScopeService context)
        {
            return context.GetScopes().Adapt<List<ScopeDto>>();
        }

        public ScopeDto GetScopeById(Guid id, [Service] IScopeService context)
        {
            return context.GetScopeById(id).Adapt<ScopeDto>();
        }
    }
}