using AuthServer.Data;
using AuthServer.Utilities;
using AutoMapper;
using IdentityServer4.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace AuthServer.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ControllerBase: Controller
    {
        private IControllerUtils Utils { get; }
        public IMapper Mapper { get; }
        public IIdentityServerDbContext DbContext { get; }
        public ILogger Logger { get; }
        public IIdentityServerInteractionService Interaction { get; }
        public IStores Stores { get; }
        public IEventService Events { get; }

        protected ControllerBase(IControllerUtils utils)
        {
            Utils = utils;
            Mapper = utils.Mapper;
            DbContext = utils.Context;
            Logger = utils.Logger;
            Interaction = utils.Interaction;
            Stores = utils.Stores;
            Events = utils.Events;
        }
    }
}