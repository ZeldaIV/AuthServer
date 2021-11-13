using AuthServer.Utilities;
using Microsoft.AspNetCore.Mvc;

namespace AuthServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ApiBaseController: ControllerBase
    {
        private IControllerUtils Utils { get; }
        private IStores Stores { get; }

        protected ApiBaseController(IControllerUtils utils)
        {
            Utils = utils;
            Stores = utils.Stores;
        }
    }
}