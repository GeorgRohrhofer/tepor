using ManagementBackend.DataModels;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Net.Http;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;

namespace ManagementBackend.Services
{
    public class MonitoringComService
    {
        private readonly string _ipAdress;
        private readonly IServiceScopeFactory _scopeFactory;
        private HttpClient httpClient;

        public MonitoringComService(string ipAdress, IServiceScopeFactory scopeFactory)
        {
            this._ipAdress = ipAdress;
            httpClient = new HttpClient();
            _scopeFactory = scopeFactory;
        }

        public async Task<Dictionary<Guid, MonitoringElement>> GetMonitoringData()
        {
            var url = _ipAdress + "/monitor/all";

            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<MyDbContext>();
            db.Logs.Add(new Log() { Id=Guid.NewGuid(), RamUsage=69.420});
            await db.SaveChangesAsync();

            var response = await httpClient.GetAsync(url);
            var jsonString = response.Content.ReadAsStringAsync().Result;
            var result = JsonSerializer.Deserialize<Dictionary<Guid, MonitoringElement>>(jsonString);

            return result;
        }

        public Guid GetLeastUsedActiveNodeId()
        {
            var allNodes = GetMonitoringData().Result;

            var allActiveNodes = allNodes.Where(an => an.Value.StillActive == true);

            var minScore = 100;
            var minNodeId = Guid.Empty;
            foreach(var node in allActiveNodes)
            {
                var score = CalculatePerformanceScore(node.Value);

                if(score < minScore)
                {
                    minScore = score;
                    minNodeId = node.Key;
                }
            }

            return minNodeId;
        }

        public List<Guid> GetActiveNodes()
        {
            var allNodes = GetMonitoringData().Result;

            var activeNodes = allNodes.Where(an => an.Value.StillActive == true).Select(an => an.Key).ToList();

            return activeNodes;
        }

        private int CalculatePerformanceScore(MonitoringElement node)
        {
            int score = 0;

            score += (int)node.MemoryUsage / 5;
            score += (int)node.CpuUsage;
            score += (int)node.DiskUsage / 4;

            return score;
        }
    }

    public class MonitoringElement()
    {
        public required double MemoryUsage { get; set; }
        public required double CpuUsage { get; set; }
        public required double DiskUsage { get; set; } 
        public required double[] NetworkUsage { get; set; }
        public required DateTime LastUpdated { get; set; }
        public required bool StillActive { get; set; }
    }
}
