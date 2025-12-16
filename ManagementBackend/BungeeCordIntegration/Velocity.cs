using System;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace BungeeCordIntegration
{
    public class Velocity(string host, int port)
    {
        public void Register(string Name, string ipAddress, int port) {
            ServerMessage obj = new ServerMessage() {
                register = true,
                serverName = Name,
                ipAddress = ipAddress,
                port = port
            };

            Send(obj);
        }
        
        public void Unregister(string Name, string ipAddress, int port) {
            ServerMessage obj = new ServerMessage() {
                register = false,
                serverName = Name,
                ipAddress = ipAddress,
                port = port
            };

            Send(obj);
        }

        private void Send(ServerMessage obj) {
            using var client = new TcpClient();
            client.Connect(host, port);
        
            using var stream = client.GetStream();
            stream.WriteByte(1);
        
            string json = JsonSerializer.Serialize(obj);
            byte[] jsonBytes = Encoding.UTF8.GetBytes(json);
        
            byte[] lengthBytes = BitConverter.GetBytes(jsonBytes.Length);
            stream.Write(lengthBytes, 0, lengthBytes.Length);
        
            stream.Write(jsonBytes, 0, jsonBytes.Length);
        
           stream.Flush();
        }
    }
}
