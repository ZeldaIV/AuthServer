using System;
using System.Collections.Generic;
using System.Linq;
using AuthServer.Dtos;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.Scope
{
    public class ScopeQuery
    {
        public List<ScopeDto> GetScopes([Service] IScopeService context)
        {
            return context.GetAll().Adapt<List<ScopeDto>>();
        }
        
        

        public ScopeDto GetScopeById(Guid id, [Service] IScopeService context)
        {
            return context.GetById(id).Adapt<ScopeDto>();
        }
    }
}