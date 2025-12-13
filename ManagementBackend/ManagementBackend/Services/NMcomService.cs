using ManagementBackend.DataModels;
using ManagementBackend.resources;
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
        private Dictionary<Guid, Socket> connectedSockets;
        private MyDbContext db;
        private readonly DiscordMessageSender _discordSender;

        public NMcomService(MyDbContext db, DiscordMessageSender discordSender)
        {
            _discordSender = discordSender;
            this.db = db;
            _listener = new TcpListener(IPAddress.Any, TcpPort);
            connectedSockets = new Dictionary<Guid, Socket>();
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _listener.Start();
            _ = ListenForConnectionsAsync(cancellationToken);

            return Task.CompletedTask;
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _listener.Stop();

            return Task.CompletedTask;
        }

        private async Task ListenForConnectionsAsync(CancellationToken cancellationToken)
        {
            try
            {
                while (!cancellationToken.IsCancellationRequested)
                {
                    var socket = await _listener.AcceptSocketAsync();  // Accept an incoming client socket
                    connectedSockets.Add(Guid.Parse("00000000-0000-0000-0000-000000000000"), socket);
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
                    await ProcessMessage(stream);
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

        private async Task ProcessMessage(NetworkStream stream)
        {
            var (type, json) = NMcomMessages.ReadMessage(stream);

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            options.Converters.Add(new FlexibleGuidConverter());

            switch (type)
            {
                case "HELOReq":
                    var heloReq = JsonSerializer.Deserialize<NMPMessage<HELOReqData>>(json, options);
                    HandleHeloRequest(heloReq, stream.Socket);
                    break;
                case "WorldSaved":
                    var worldSaved = JsonSerializer.Deserialize<NMPMessage<WorldSavedData>>(json, options);
                    if (worldSaved != null)
                    {
                        HandleWorldSaved(worldSaved);
                    }
                    break;
                case "ERROR":
                    var error = JsonSerializer.Deserialize<NMPMessage<ErrorData>>(json, options);
                    if (error != null)
                    {
                        HandleError(error);
                    }
                    break;
                case "QUIT":
                    HandleQuit(stream.Socket);
                    break;
                default:
                    Console.WriteLine($"Received unsupported command type: {type}");
                    break;
            }
        }

        private async Task HandleHeloRequest(NMPMessage<HELOReqData> heloReq, Socket socket)
        {
            if (heloReq == null || heloReq.data == null)
                return;

            var nodeInDb = db.Nodes.FirstOrDefault(n => n.Id == heloReq.data.previous_id);

            if (nodeInDb == null)
            {
                db.Nodes.Add(new Node
                {
                    Id = heloReq.data.previous_id,
                    Ram = 0,
                    Cpu = 0
                });
                await db.SaveChangesAsync();
            }

            connectedSockets[heloReq.data.previous_id] = socket;

            var helloRespData = new HELORespData {active_id = heloReq.data.previous_id};
            var messageObject = new NMPMessage<HELORespData>("HELOResp", helloRespData);
            await SendMessage(messageObject, heloReq.data.previous_id);
        }

        private async Task HandleWorldSaved(NMPMessage<WorldSavedData> worldSaved)
        {
            if (worldSaved == null || worldSaved.data == null)
                return;

            var world = db.Worlds.FirstOrDefault(w => w.Id == worldSaved.data.world_id);

            if (world == null)
                return;

            world.Hash = worldSaved.data.hash;
            await db.SaveChangesAsync();
        }

        private async Task HandleError(NMPMessage<ErrorData> error)
        {
            if (error == null || error.data == null)
                return;

            await _discordSender.SendDm("Error from Node: " + error.data.message, _discordSender.discordBotUserIds.ToArray());
        }

        private async Task HandleQuit(Socket socket)
        {
            socket.Close();
        }

        private async Task SendMessage<T>(NMPMessage<T> messageObject, Guid nodeId)
        {
            var socket = connectedSockets.GetValueOrDefault(nodeId);

            if (socket == null || !socket.Connected)
            {
                Console.WriteLine("Socket not connected. Cannot send message.");
                return;
            }

            var message = NMcomMessages.CreateMessage<T>(messageObject);

            var kek = await socket.SendAsync(message);
        }
    }
}
