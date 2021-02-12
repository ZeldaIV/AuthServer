using AuthServer.Data;
using IdentityServer4.Services;
using MapsterMapper;

namespace AuthServer.Utilities
{
    public interface IControllerUtils
    {
        public IIdentityServerInteractionService Interaction { get; }
        public IStores Stores { get; }
        public IEventService Events { get; }
        public IIdentityServerDbContext Context { get; }
        public IMapper Mapper { get; }
    }
}