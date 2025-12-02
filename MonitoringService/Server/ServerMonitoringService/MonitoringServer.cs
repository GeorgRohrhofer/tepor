using SharedLibraries;
using System.Collections.Concurrent;
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
        private ConcurrentDictionary<string, MonitoringData> _clients = new();
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
            Thread listenerThread = new(_Listener);
            listenerThread.Start();
            threadList.Add(listenerThread);
        }

        private void _Listener()
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

                    Thread thread = new(_ClientHandler);
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

        private void _ClientHandler(object? clientObject)
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
                    int bytesRead = stream.Read(bytesReceived, 0, bytesReceived.Length);
                    if (bytesRead == 0)
                        break;

                    string jsonString = Encoding.UTF8.GetString(bytesReceived, 0, bytesRead);

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

                            _HandleMonitoringMessage(dataMessage, client.Client.RemoteEndPoint?.ToString() ?? "Unknown");
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

        private void _HandleMonitoringMessage(MonitoringMessage data, string clientEndpoint)
        {
            // Display received data, left in for now for debugging
            Console.WriteLine($"\n=== System-Daten von {clientEndpoint} ===");
            Console.WriteLine($"NodeID:  {data.NodeID}");
            Console.WriteLine($"CPU:     {data.CpuUsage}");
            Console.WriteLine($"Memory:  {data.MemoryUsage}");
            Console.WriteLine($"Disk:    {data.DiskUsage}");
            Console.WriteLine($"Network: {data.NetworkUsage[0]}, {data.NetworkUsage[1]} ");
            Console.WriteLine($"Time:    {DateTime.Now:HH:mm:ss}");

            _clients.AddOrUpdate(
                data.NodeID,
                key =>
                new MonitoringData
                {
                    CpuUsage = data.CpuUsage,
                    MemoryUsage = data.MemoryUsage,
                    DiskUsage = data.DiskUsage,
                    NetworkUsage = data.NetworkUsage,
                    LastUpdated = DateTime.Now,
                    StillActive = true
                },
                (key, existing) => new MonitoringData
                {
                    CpuUsage = data.CpuUsage,
                    MemoryUsage = data.MemoryUsage,
                    DiskUsage = data.DiskUsage,
                    NetworkUsage = data.NetworkUsage,
                    LastUpdated = DateTime.Now,
                    StillActive = true
                }
            );
        }

        public void Stop()
        {
            _WaitForShutdown();
            _isRunning = false;
            Console.WriteLine("Server is shutting down...");
        }

        private void _WaitForShutdown()
        {
            foreach (var thread in threadList)
            {
                thread.Join();
            }
        }

        public IReadOnlyDictionary<string, MonitoringData> GetClientsSnapshot()
        {
            var snapshot = _clients.ToDictionary(kvp => kvp.Key, kvp => kvp.Value);
            return new System.Collections.ObjectModel.ReadOnlyDictionary<string, MonitoringData>(snapshot);
        }
    }
}
