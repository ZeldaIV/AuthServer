using AuthServer.Data;
using AutoMapper;
using IdentityServer4.Services;
using Microsoft.Extensions.Logging;

namespace AuthServer.Utilities
{
    public class ControllerUtils: IControllerUtils
    {
        public IIdentityServerInteractionService Interaction { get; }
        public IStores Stores { get; }
        public IEventService Events { get; }
        public IIdentityServerDbContext Context { get; }
        public IMapper Mapper { get; }

        public ControllerUtils(IIdentityServerInteractionService interaction,
            IStores stores,
            IEventService events,
            IIdentityServerDbContext context, 
            IMapper mapper)
        {
            Interaction = interaction;
            Stores = stores;
            Events = events;
            Context = context;
            Mapper = mapper;
        }
    }
}