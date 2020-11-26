using AuthServer.Data;
using AutoMapper;
using IdentityServer4.Services;
using Microsoft.Extensions.Logging;

namespace AuthServer.Utilities
{
    public interface IControllerUtils
    {
        public IIdentityServerInteractionService Interaction { get; }
        public IStores Stores { get; }
        public IEventService Events { get; }
        public IIdentityServerDbContext Context { get; }
        public IMapper Mapper { get; }
        public ILogger Logger { get; }
        
    }
}