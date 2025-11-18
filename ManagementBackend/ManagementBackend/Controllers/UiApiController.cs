using ManagementBackend.resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
        [HttpGet("GetUiData")]
        public string TestEndpoint()
        {
            return "Here is your dummy Ui Data";
        }

        [HttpGet("GetNodes")]
        public string GetNodes()
        {
            var nodes = new List<Node>
            {
                new Node { Name = "Node A", Id = Guid.NewGuid() },
                new Node { Name = "Node B", Id = Guid.NewGuid() },
                new Node { Name = "Node C", Id = Guid.NewGuid() }
            };

            string json = JsonSerializer.Serialize(nodes);

            return json;
        }

        [HttpGet("GetNodeDetails")]
        public string GetNodeDetails()
        {
            var nodeDetails = new NodeDetails
            {
                Name = "Node A",
                Id = Guid.NewGuid(),
                State = "Active",
                Description = "This is a sample node used for demonstration purposes.",
                Settings = "Default Settings",
                Ip = "123.456.789.111"
            };

            string json = JsonSerializer.Serialize(nodeDetails);

            return json;
        }
    }

    public class Node
    {
        public string Name { get; set; }
        public Guid Id { get; set; }
    }

    public class NodeDetails
    {
        public string Name { get; set; }
        public Guid Id { get; set; }
        public string State { get; set; }
        public string Description { get; set; }
        public string Settings { get; set; }
        public string Ip { get; set; }
    }
}
