using AuthServer.Data;
using AuthServer.Utilities;
using IdentityServer4.Services;
using MapsterMapper;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ApiBaseController: ControllerBase
    {
        private IControllerUtils Utils { get; }
        public IMapper Mapper { get; }
        public IIdentityServerDbContext DbContext { get; }
        public IIdentityServerInteractionService Interaction { get; }
        public IStores Stores { get; }
        public IEventService Events { get; }

        protected ApiBaseController(IControllerUtils utils)
        {
            Utils = utils;
            Mapper = utils.Mapper;
            DbContext = utils.Context;
            Interaction = utils.Interaction;
            Stores = utils.Stores;
            Events = utils.Events;
        }
    }
}