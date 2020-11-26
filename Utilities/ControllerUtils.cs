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
        public ILogger Logger { get; }

        public ControllerUtils(IIdentityServerInteractionService interaction,
            IStores stores,
            IEventService events,
            ILogger logger, 
            IIdentityServerDbContext context, 
            IMapper mapper)
        {
            Interaction = interaction;
            Stores = stores;
            Events = events;
            Logger = logger;
            Context = context;
            Mapper = mapper;
        }
    }
}