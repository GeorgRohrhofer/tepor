using ManagementBackend.DataModels;
using ManagementBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace ManagementBackend.Controllers
{
    [ApiController]
    [Route("TestApi")]
    [Authorize(Roles = "admin")]
    public class TestController : ControllerBase
    {
        private readonly MonitoringComService _monitoringComService;
        private readonly DiscordMessageSender _discordSender;
        private MyDbContext db;

        public TestController(DiscordMessageSender discordSender, MyDbContext db, MonitoringComService monitoringComService)
        {
            _monitoringComService = monitoringComService;
            _discordSender = discordSender;
            this.db = db;
        }

        [HttpPost("SendDiscordDm")]
        public async Task<ObjectResult> SendDiscordDm(
            [FromHeader(Name = "message")] string message,
            [FromHeader(Name = "ids")] string[] ids)
        {
            await _discordSender.SendDm(message, ids);

            return Ok("Message Sent");
        }

        [HttpPost("SendDiscordMessage")]
        public async Task<ObjectResult> SendDiscordMessage(
            [FromHeader(Name = "message")] string message,
            [FromHeader(Name = "ids")] string[] ids)
        {
            await _discordSender.SendMessageToChannel(message, ids);

            return Ok("Message Sent");
        }

        [HttpGet("MonitoringData")]
        public async Task<ObjectResult> MonitoringData()
        {
            return Ok(await _monitoringComService.GetMonitoringData());
        }
    }
}
