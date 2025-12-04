using Microsoft.Extensions.Hosting;
using System.Net;
using System.Net.Sockets;
using System.Text.Json;

namespace ManagementBackend.Services
{
    public class NMcomService : IHostedService
    {
        private readonly TcpListener _listener;
        private const int TcpPort = 25565;
        private const byte ProtocolVersion = 0x01;
        private const int HeaderSize = 5; // 1 Byte Version + 3 Bytes Länge

        //todo make list
        private Socket _connectedSocket;

        public NMcomService()
        {
            _listener = new TcpListener(IPAddress.Any, TcpPort);
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _listener.Start();
            _ = ListenForConnectionsAsync();

            return Task.CompletedTask;
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _listener.Stop();

            return Task.CompletedTask;
        }

        private async Task ListenForConnectionsAsync()
        {
            try
            {
                while (true)
                {
                    var socket = await _listener.AcceptSocketAsync();  // Accept an incoming client socket
                    _connectedSocket = socket;
                    _ = HandleConnection(socket);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Wait for Socket Error: " + ex);
            }
            finally
            {
                _listener.Stop(); // Stop listening when loop finishes
            }
        }

        private async Task HandleConnection(Socket socket)
        {
            var stream = new NetworkStream(socket);

            try
            {
                while (socket.Connected)
                {
                    await ReadMessage(stream);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Network Stream Error: " + ex);
            }
            finally
            {
                stream.Close();
                socket.Close();
            }
        }

        private async Task ReadMessage(NetworkStream stream)
        {
            byte[] headerBuffer = new byte[HeaderSize];

            if (await ReadFullyAsync(stream, headerBuffer, HeaderSize) != HeaderSize)
            {
                return;
            }

            byte version = headerBuffer[0];
            //int messageLength = (headerBuffer[1] << 16) | (headerBuffer[2] << 8) | headerBuffer[3];
            int messageLength = (headerBuffer[1] << 24) | (headerBuffer[2] << 16) | (headerBuffer[3] << 8) | headerBuffer[4];


            Console.WriteLine($"Protocol Version: {version}, Message Length: {messageLength} bytes");

            if (messageLength > 0)
            {
                byte[] messageBuffer = new byte[messageLength];
                if (await ReadFullyAsync(stream, messageBuffer, messageLength) == messageLength)
                {
                    ProcessMessage(version, messageBuffer);
                }
            }
        }

        private async Task<int> ReadFullyAsync(Stream stream, byte[] buffer, int count)
        {
            int totalBytesRead = 0;
            while (totalBytesRead < count)
            {
                int bytesRead = await stream.ReadAsync(buffer, totalBytesRead, count - totalBytesRead);

                if (bytesRead == 0) // Stream-Ende erreicht, bevor alle Bytes gelesen wurden
                    break;

                totalBytesRead += bytesRead;
            }
            return totalBytesRead;
        }

        private async Task ProcessMessage(byte version, byte[] messageData)
        {
            string messageJson = System.Text.Encoding.UTF8.GetString(messageData);
            Console.WriteLine($"Processed message (Version {version}): {messageJson}");

            try
            {
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };

                // Peek at the type using the non-generic wrapper
                var baseMessage = JsonSerializer.Deserialize<NMPMessage>(messageJson, options);

                if (baseMessage == null || string.IsNullOrEmpty(baseMessage.type))
                {
                    Console.WriteLine("Invalid NMP message format.");
                    return;
                }

                switch (baseMessage.type)
                {
                    case "HELOReq":
                        // Deserialize the entire payload into the specific type wrapper
                        var heloReqWrapper = JsonSerializer.Deserialize<NMPMessage<HELOReqData>>(messageJson, options);

                        if (heloReqWrapper?.data != null)
                        {
                            // Access the directly converted Guid property
                            Guid receivedGuid = heloReqWrapper.data.previous_id;
                            Console.WriteLine($"Received HELOReq with ID: {receivedGuid}");

                            await SendHelloResponse(receivedGuid);
                        }
                        break;

                    case "QUIT":
                        Console.WriteLine("Received QUIT command. Closing connection.");
                        break;

                    // Add other cases here
                    default:
                        Console.WriteLine($"Received unsupported command type: {baseMessage.type}");
                        break;
                }
            }
            catch (JsonException ex)
            {
                // This catch block will only trigger if the JSON is malformed or the GUID
                // is not in a standard format (e.g., still has braces).
                Console.WriteLine($"JSON Deserialization error: {ex.Message}");
            }
        }

        // Generic wrapper for specific data payloads
        public class NMPMessage<T>
        {
            public string type { get; set; }
            public T data { get; set; }
        }

        public class NMPMessage
        {
            public string type { get; set; }
            public object data { get; set; }
        }

        public class ServerCreateData
        {
            public string world_id { get; set; }
            public string config { get; set; }
        }

        public class HELORespData
        {
            public Guid active_id { get; set; }
        }

        public class HELOReqData
        {
            // Matches the "previous_id" field in the NMP spec
            public Guid previous_id { get; set; }
        }

        public async Task SendHelloResponse(Guid socketGuid)
        {
            var helloData = new HELORespData { active_id = socketGuid };
            var messageObject = new NMPMessage { type = "HELOResp", data = helloData };

            SendMessage(messageObject);
        }

        public void SendCreateServer(string config)
        {
            var worldId = Guid.NewGuid().ToString();

            var createData = new ServerCreateData { world_id = worldId, config = config };
            var messageObject = new NMPMessage { type = "ServerCreate", data = createData };

            SendMessage(messageObject);
        }

        private void SendMessage(NMPMessage messageObject)
        {
            if (_connectedSocket == null || !_connectedSocket.Connected)
            {
                Console.WriteLine("Socket not connected. Cannot send message.");
                return;
            }

            string jsonPayload = JsonSerializer.Serialize(messageObject);
            byte[] payloadBytes = System.Text.Encoding.UTF8.GetBytes(jsonPayload);
            int payloadLength = payloadBytes.Length;

            byte[] frame = new byte[1 + 4 + payloadLength];

            frame[0] = ProtocolVersion;

            byte[] lengthBytes = BitConverter.GetBytes(payloadLength);
            if (BitConverter.IsLittleEndian)
            {
                Array.Reverse(lengthBytes);
            }
            Array.Copy(lengthBytes, 0, frame, 1, 4);
            Array.Copy(payloadBytes, 0, frame, 5, payloadLength);

            var kek = _connectedSocket.Send(frame);
            Console.WriteLine($"Sent message of type {messageObject.type} with length {payloadLength} bytes.");
        }
    }
}
