using System.Text;
using System.Text.Json;

namespace ManagementBackend.resources
{
    public class DiscordMessageSender
    {
        private string ipAdress;
        private HttpClient httpClient;

        public DiscordMessageSender(string ipAdress)
        {
            this.ipAdress = ipAdress;
            this.httpClient = new HttpClient();
        }

        public async Task SendMessageToChannel(string messageContent, string[] channelIds)
        {
            var messageObj = new DiscordMessage(messageContent, channelIds);
            var messageJson = JsonSerializer.Serialize(messageObj);
            var content = new StringContent(messageJson, Encoding.UTF8, "application/json");

            var url = ipAdress + "/message/send/channel";

            var response = await httpClient.PostAsync(ipAdress, content);

            // Log Response
        }

        public async Task SendDm(string messageContent, string[] userIds)
        {
            var messageObj = new DiscordMessage(messageContent, userIds);
            var messageJson = JsonSerializer.Serialize(messageObj);
            var content = new StringContent(messageJson, Encoding.UTF8, "application/json");

            var url = ipAdress + "/message/send/direct";

            var response = await httpClient.PostAsync(ipAdress, content);

            // Log Response
        }
    }

    public class DiscordMessage
    {
        public string Message { get; set; }

        public string[] Ids { get; set; }

        public DiscordMessage(string message, string[] ids)
        {
            Message = message;
            Ids = ids;
        }
    }
}
