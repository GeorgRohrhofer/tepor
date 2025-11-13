using ManagementBackend.resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ManagementBackend.Controllers
{
    [ApiController]
    [Route("UiApi")]
    [Authorize]
    public class UiApiController : ControllerBase
    {
        [HttpGet("GetUiData")]
        public string TestEndpoint()
        {
            return "Here is your dummy Ui Data";
        }
    }
}
