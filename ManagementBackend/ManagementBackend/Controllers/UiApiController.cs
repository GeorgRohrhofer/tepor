using ManagementBackend.DataModels;
using ManagementBackend.resources;
using ManagementBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Xml.Linq;

namespace ManagementBackend.Controllers
{
    [ApiController]
    [Route("UiApi")]
    [Authorize]
    public class UiApiController : ControllerBase
    {
        private readonly DiscordMessageSender _discordSender;
        private readonly NMcomService _nmComService;
        private MyDbContext db;

        public UiApiController(DiscordMessageSender discordSender, NMcomService nmComService, MyDbContext db)
        {
            _discordSender = discordSender;
            _nmComService = nmComService;
            this.db = db;
        }

        [HttpGet("GetUserName")]
        public ObjectResult GetUserName()
        {
            return Ok(User.FindFirst("username")?.Value ?? "No username found.");
        }

        [HttpGet("GetRoles")]
        public ObjectResult GetRoles()
        {
            var roles = string.Empty;

            if (User.IsInRole("user"))
                roles += "user\n";

            if (User.IsInRole("admin"))
                roles += "admin\n";

            return Ok(roles);
        }

        [HttpGet("GetNodes")]
        public ObjectResult GetNodes()
        {
            var nodes = db.Nodes.ToList();
            string json = JsonSerializer.Serialize(nodes);

            return Ok(json);
        }

        [HttpGet("GetNode")]
        public ObjectResult GetNodes([FromHeader(Name = "nodeId")] Guid nodeId)
        {
            var node = db.Nodes.Where(n => n.Id == nodeId).FirstOrDefault();
            string json = JsonSerializer.Serialize(node);

            return Ok(json);
        }

        [HttpGet("GetWorldsByCurrentUser")]
        public ObjectResult GetWorldsByCurrentUser()
        {
            var ownerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (ownerId == null)
                return BadRequest("User ID not found in token.");

            var worlds = db.Worlds.Where(w => w.OwnerId == Guid.Parse(ownerId));
            string json = JsonSerializer.Serialize(worlds);

            return Ok(json);
        }

        [HttpGet("GetWorldsByNode")]
        public ObjectResult GetWorldsByNode([FromHeader(Name = "nodeId")] Guid nodeId)
        {
            var worlds = db.Worlds.Where(w => db.WorldStores.Any(ws => ws.RunningNodeId == nodeId && ws.WorldId == w.Id)).ToList();
            string json = JsonSerializer.Serialize(worlds);

            return Ok(json);
        }

        [HttpGet("GetWorld")]
        public ObjectResult GetWorld([FromHeader(Name = "worldId")] Guid worldId)
        {
            var world = db.Worlds.Where(w => w.Id == worldId).FirstOrDefault();
            string json = JsonSerializer.Serialize(world);

            return Ok(json);
        }

        [HttpPost("CreateWorld")]
        public ObjectResult CreateWorld([FromBody] CreateWorldRequest request)
        {
            if (request == null)
                return BadRequest("Invalid request body.");

            var ownerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (ownerId == null)
                return BadRequest("User ID not found in token.");

            var world = new World()
            {
                Id = Guid.NewGuid(),
                Name = request.WorldName,
                Hash = "",
                Config = request.WorldConfig,
                OwnerId = Guid.Parse(ownerId),
            };

            var allNodes = db.Nodes.ToList();
            var random = new Random();
            var node = allNodes[random.Next(allNodes.Count)];

            var worldStore = new WorldStore()
            {
                Id = Guid.NewGuid(),
                WorldId = world.Id,
                RunningNodeId = node.Id,
                BackUpNodeIds = new List<Guid>(),
            };

            if (!_nmComService.SendCreateServer(world.Id, world.Config, node.Id))
                return Problem("Failed to Create the World.");
            if(!_nmComService.SendStartServer(world.Id, node.Id))
                return Problem("Failed to Start the World.");

            db.Worlds.Add(world);
            db.WorldStores.Add(worldStore);
            db.SaveChanges();

            return Ok("World Created with ID: " + world.Id);
        }

        [HttpDelete("DeleteWorld")]
        public ObjectResult DeleteWorld([FromHeader(Name = "worldId")] Guid worldId)
        {
            var nodeId = db.WorldStores.Where(ws => ws.WorldId == worldId).Select(ws => ws.RunningNodeId).FirstOrDefault();
            if (!_nmComService.SendStopServer(worldId, nodeId))
                return Problem("Failed to Stop the World.");
            if (!_nmComService.SendDeleteServer(worldId, nodeId))
                return Problem("Failed to Delete the World.");

            db.Worlds.RemoveRange(db.Worlds.Where(w => w.Id == worldId));

            return Ok("World Deleted with ID: " + worldId);
        }

        [HttpGet("GetDiscordIDs")]
        public ObjectResult GetDiscordIDs()
        {
            var discordIds = _discordSender.discordBotUserIds;
            string json = JsonSerializer.Serialize(discordIds);

            return Ok(json);
        }

        [HttpPost("SetDiscordIDs")]
        public ObjectResult SetDiscordIDs([FromBody] List<string> discordIds)
        {
            _discordSender.discordBotUserIds.AddRange(discordIds);

            return Ok("Ids Saved");
        }

        public class CreateWorldRequest
        {
            public required string WorldName { get; set; }

            public required string WorldConfig { get; set; }
        }
    }
}
