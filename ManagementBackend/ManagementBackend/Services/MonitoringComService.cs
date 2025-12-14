using ManagementBackend.DataModels;
using System.Net.Http;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;

namespace ManagementBackend.Services
{
    public class MonitoringComService
    {
        private string ipAdress = "http://127.0.0.1:6943";
        private MyDbContext db;
        private HttpClient httpClient;

        public MonitoringComService(MyDbContext db)
        {
            httpClient = new HttpClient();
            this.db = db;
        }

        public async Task<string> GetMonitoringData()
        {
            var url = ipAdress + "/monitor/all";

            var response = await httpClient.GetAsync(url);
            return response.Content.ReadAsStringAsync().Result;
        }
    }
}
