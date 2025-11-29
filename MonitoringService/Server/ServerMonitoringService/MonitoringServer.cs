using SharedLibraries;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;

namespace ServerMonitoringService
{
    public class MonitoringServer
    {
        private int _port;

        List<Thread> threadList = new();
        private readonly JsonSerializerOptions _jsonOptions;
        bool _isRunning = true;


        public MonitoringServer(int port)
        {
            _port = port;

            _jsonOptions = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
                WriteIndented = false
            };
        }

        public void Start()
        {
            Thread listenerThread = new(Listener);
            listenerThread.Start();
            threadList.Add(listenerThread);
        }

        public void Listener()
        {
            TcpListener tcpListener = new TcpListener(IPAddress.Any, _port);
            tcpListener.Start();
            Console.WriteLine($"Monitoring Server started on Port {_port}");

            while (_isRunning)
            {
                try
                {
                    Console.WriteLine("Waiting for client connections...");
                    TcpClient client = tcpListener.AcceptTcpClient();

                    Thread thread = new(ClientHandler);
                    thread.Start(client);
                    threadList.Add(thread);
                    Console.WriteLine("Client connected: " + client.Client.RemoteEndPoint?.ToString());
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error in Listener: " + ex.Message);
                }
            }
            tcpListener.Stop();
        }

        public void ClientHandler(object? clientObject)
        {
            if (clientObject != null && clientObject is TcpClient client)
            {
                NetworkStream stream = client.GetStream();
                while (_isRunning && client.Connected)
                {
                    if (!stream.DataAvailable)
                    {
                        Thread.Sleep(100);
                        continue;
                    }

                    byte[] bytesReceived = new byte[8192];
                    stream.Read(bytesReceived, 0, bytesReceived.Length);
                    if (bytesReceived.Length == 0)
                        break;
                    string jsonString = Encoding.UTF8.GetString(bytesReceived).TrimEnd('\0');

                    if (bytesReceived[0] == 1)
                    {
                        try
                        {
                            var dataMessage = JsonSerializer.Deserialize<MonitoringMessage>(jsonString[1..], _jsonOptions);

                            if (dataMessage == null)
                            {
                                Console.WriteLine("Invalid message received");
                                continue;
                            }

                            if (dataMessage != null)
                            {
                                HandleMonitoringMessage(dataMessage, client.Client.RemoteEndPoint?.ToString() ?? "Unknown");
                            }

                        }
                        catch (JsonException ex)
                        {
                            Console.WriteLine($"JSON Error: {ex.Message}");
                        }
                    }
                    else
                    {
                        throw new FormatException("Message version invalid.");
                    }
                }
            }
        }

        private void HandleMonitoringMessage(MonitoringMessage data, string clientEndpoint)
        {
            Console.WriteLine($"\n=== System-Daten von {clientEndpoint} ===");
            Console.WriteLine($"NodeID:  {data.NodeID}");
            Console.WriteLine($"CPU:     {data.CpuUsage}");
            Console.WriteLine($"Memory:  {data.MemoryUsage}");
            Console.WriteLine($"Disk:    {data.DiskUsage}");
            Console.WriteLine($"Network: {data.NetworkUsage[0]}, {data.NetworkUsage[1]} ");
            Console.WriteLine($"Time:    {DateTime.Now:HH:mm:ss}");
        }

        public void Stop()
        {
            _isRunning = false;
            Console.WriteLine("Server is shutting down...");
        }
    }
}
