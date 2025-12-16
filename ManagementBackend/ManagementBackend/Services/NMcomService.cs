using ManagementBackend.DataModels;
using Microsoft.Extensions.Hosting;
using System.Net;
using System.Net.Sockets;
using System.Text.Json;

namespace ManagementBackend.Services
{
    public class NMcomService : IHostedService
    {
        private readonly TcpListener _listener;
        private const int TcpPort = 5278;
        private Dictionary<Guid, Socket> connectedSockets;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly DiscordMessageSender _discordSender;

        public NMcomService(IServiceScopeFactory scopeFactory, DiscordMessageSender discordSender)
        {
            _scopeFactory = scopeFactory;
            _discordSender = discordSender;
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
                    var socket = await _listener.AcceptSocketAsync();
                    _ = Task.Run(() => HandleConnection(socket));
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Wait for Socket Error: " + ex);
            }
            finally
            {
                _listener.Stop();
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
                HandleQuit(socket);
            }
        }

        private async Task ProcessMessage(NetworkStream stream)
        {
            var (type, json) = NMcomMessages.ReadMessage(stream);

            if (type == null || json == null)
            {
                HandleQuit(stream.Socket);
                return;
            }

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            options.Converters.Add(new FlexibleGuidConverter());

            switch (type)
            {
                case "HELOReq":
                    var heloReq = JsonSerializer.Deserialize<NMPMessage<HELOReqData>>(json, options);
                    _ = HandleHeloRequest(heloReq, stream.Socket);
                    break;
                case "WorldSaved":
                    var worldSaved = JsonSerializer.Deserialize<NMPMessage<WorldSavedData>>(json, options);
                    _ = HandleWorldSaved(worldSaved);
                    break;
                case "ERROR":
                    var error = JsonSerializer.Deserialize<NMPMessage<ErrorData>>(json, options);
                    _ = HandleError(error);
                    break;
                case "QUIT":
                    HandleQuit(stream.Socket);
                    break;
                default:
                    Console.WriteLine($"Received unsupported command type: {type}");
                    break;
            }
        }

        private async Task HandleHeloRequest(NMPMessage<HELOReqData> ?heloReq, Socket socket)
        {
            if (heloReq == null || heloReq.data == null)
                return;

            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<MyDbContext>();

            var nodeInDb = db.Nodes.Where(n => n.Id == heloReq.data.previous_id).Any();

            if (!nodeInDb)
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

            var helloRespData = new HELORespData { active_id = heloReq.data.previous_id };
            var messageObject = new NMPMessage<HELORespData>("HELOResp", helloRespData);
            await SendMessage(messageObject, heloReq.data.previous_id);
        }

        private async Task HandleWorldSaved(NMPMessage<WorldSavedData> ?worldSaved)
        {
            if (worldSaved == null || worldSaved.data == null)
                return;

            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<MyDbContext>();

            var world = db.Worlds.FirstOrDefault(w => w.Id == worldSaved.data.world_id);

            if (world == null)
                return;

            world.Hash = worldSaved.data.hash;
            await db.SaveChangesAsync();
        }

        private async Task HandleError(NMPMessage<ErrorData> ?error)
        {
            if (error == null || error.data == null)
                return;

            await _discordSender.SendDm("Error from Node: " + error.data.message, _discordSender.discordBotUserIds.ToArray());
        }

        private void HandleQuit(Socket socket)
        {
            socket.Close();

            var idToRemove = connectedSockets.FirstOrDefault(x => x.Value == socket).Key;
            connectedSockets.Remove(idToRemove);
        }

        private async Task<bool> SendMessage<T>(NMPMessage<T> messageObject, Guid nodeId)
        {
            var socket = connectedSockets.GetValueOrDefault(nodeId);

            if (socket == null || !socket.Connected)
            {
                Console.WriteLine("Socket not connected. Cannot send message.");
                return false;
            }

            var message = NMcomMessages.CreateMessage<T>(messageObject);

            var bytesTransfered = await socket.SendAsync(message);

            return bytesTransfered == message.Length;
        }

        public bool SendCreateServer(Guid worldId, string config, Guid nodeId)
        {
            NMPMessage<ServerCreateData> createMessage = new NMPMessage<ServerCreateData>(
                "ServerCreate",
                new ServerCreateData
                {
                    world_id = worldId,
                    config = config
                }
            );

            return SendMessage<ServerCreateData>(createMessage, nodeId).Result;
        }

        public bool SendStartServer(Guid worldId, Guid nodeId)
        {
            NMPMessage<ServerStartData> startMessage = new NMPMessage<ServerStartData>(
                "ServerStart",
                new ServerStartData
                {
                    world_id = worldId
                }
            );

            return SendMessage<ServerStartData>(startMessage, nodeId).Result;
        }

        public bool SendStopServer(Guid worldId, Guid nodeId)
        {
            NMPMessage<ServerStopData> stopMessage = new NMPMessage<ServerStopData>(
                "ServerStop",
                new ServerStopData
                {
                    world_id = worldId
                }
            );

            return SendMessage<ServerStopData>(stopMessage, nodeId).Result;
        }

        public bool SendRestartServer(Guid worldId, Guid nodeId)
        {
            NMPMessage<ServerRestartData> restartMessage = new NMPMessage<ServerRestartData>(
                "ServerRestart",
                new ServerRestartData
                {
                    world_id = worldId
                }
            );

            return SendMessage<ServerRestartData>(restartMessage, nodeId).Result;
        }

        public bool SendDeleteServer(Guid worldId, Guid nodeId)
        {
            NMPMessage<ServerDeleteData> deleteMessage = new NMPMessage<ServerDeleteData>(
                "ServerDelete",
                new ServerDeleteData
                {
                    world_id = worldId
                }
            );

            return SendMessage<ServerDeleteData>(deleteMessage, nodeId).Result;
        }

        public bool SendQuitNode(Guid nodeId)
        {
            NMPMessage<NMPquitData> quitMessage = new NMPMessage<NMPquitData>(
                "QUIT",
                new NMPquitData()
            );

            return SendMessage<NMPquitData>(quitMessage, nodeId).Result;
        }

        // Unused for now
        private bool SendVersionError(Guid nodeId)
        {
            NMPMessage<UnsupportedVersionData> versionMismatchMessage = new NMPMessage<UnsupportedVersionData>(
                "ERROR",
                new UnsupportedVersionData
                {
                    message = "Version mismatch between Management Backend and Node Backend.",
                    current_version = NMcomMessages.ProtocolVersion.ToString(),
                }
            );

            return SendMessage<UnsupportedVersionData>(versionMismatchMessage, nodeId).Result;
        }

        private bool SendErrorMessage(Guid nodeId, string errorMessage)
        {
            NMPMessage<ErrorData> errorMessageObject = new NMPMessage<ErrorData>(
                "ERROR",
                new ErrorData
                {
                    message = errorMessage
                }
            );

            return SendMessage<ErrorData>(errorMessageObject, nodeId).Result;
        }
    }
}
