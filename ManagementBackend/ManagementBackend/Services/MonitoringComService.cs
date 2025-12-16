using ManagementBackend.DataModels;
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

        public async Task<string> GetMonitoringData()
        {
            var url = _ipAdress + "/monitor/all";

            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<MyDbContext>();
            db.Logs.Add(new Log() { Id=Guid.NewGuid(), RamUsage=69.420});
            await db.SaveChangesAsync();

            var response = await httpClient.GetAsync(url);
            return response.Content.ReadAsStringAsync().Result;
        }
    }
}
