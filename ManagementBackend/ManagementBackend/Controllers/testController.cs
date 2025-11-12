using ManagementBackend.resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ManagementBackend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class TestController : ControllerBase
    {
        [HttpGet("TestEndpoint")]
        public string TestEndpoint()
        {
            return "Endpoint works!";
        }
    }
}
