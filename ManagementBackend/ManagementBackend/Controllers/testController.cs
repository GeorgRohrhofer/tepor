using ManagementBackend.DataModels;
using ManagementBackend.resources;
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
        private readonly DiscordMessageSender _discordSender;
        private MyDbContext db;

        public TestController(DiscordMessageSender discordSender, MyDbContext db)
        {
            _discordSender = discordSender;
            this.db = db;
        }

        [HttpGet("TestEndpoint")]
        public string TestEndpoint()
        {
            var kek = new DataModels.Node() {
                Id = Guid.NewGuid(),
                Ram = 3.1,
                Cpu = 124.052
            };

            db.Add(kek);
            db.SaveChanges();
            var bruh = db.Nodes.FirstOrDefault();

            return "Endpoint works!\n" + bruh.Id;
        }

        [HttpPost("SendDiscordDm")]
        public async Task<ObjectResult> SendDiscordDm(
            [FromHeader(Name ="message")] string message,
            [FromHeader(Name ="ids")] string[] ids)
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

        [HttpGet("WhoAmI")]
        public string WhoAmI()
        {
            return User.FindFirst("username")?.Value ?? "No username found.";
        }
    }
}
