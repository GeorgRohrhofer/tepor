using System.Text;
using System.Text.Json;

namespace ManagementBackend.Services
{
    public class DiscordMessageSender
    {
        private string ipAdress;
        private HttpClient httpClient;
        public List<string> discordBotUserIds;

        public DiscordMessageSender(string ipAdress, string discordBotDefaultUserId)
        {
            this.ipAdress = ipAdress;
            httpClient = new HttpClient();
            discordBotUserIds = new List<string>();
            discordBotUserIds.Add(discordBotDefaultUserId);
        }

        public async Task SendMessageToChannel(string messageContent, string[] channelIds)
        {
            var messageObj = new DiscordChannelMessage(messageContent, channelIds);
            var messageJson = JsonSerializer.Serialize(messageObj);
            var content = new StringContent(messageJson, Encoding.UTF8, "application/json");

            var url = ipAdress + "/message/send/channel";

            var response = await httpClient.PostAsync(ipAdress, content);
        }

        public async Task SendDm(string messageContent, string[] userIds)
        {
            var messageObj = new DiscordDm(messageContent, userIds);
            var messageJson = JsonSerializer.Serialize(messageObj);
            var content = new StringContent(messageJson, Encoding.UTF8, "application/json");

            var url = ipAdress + "/message/send/direct";

            var response = await httpClient.PostAsync(ipAdress, content);
        }
    }

    public class DiscordDm
    {
        public string messageContent { get; set; }

        public string[] directs { get; set; }

        public DiscordDm(string message, string[] ids)
        {
            messageContent = message;
            directs = ids;
        }
    }

    public class DiscordChannelMessage
    {
        public string messageContent { get; set; }

        public string[] channels { get; set; }

        public DiscordChannelMessage(string message, string[] ids)
        {
            messageContent = message;
            channels = ids;
        }
    }
}
