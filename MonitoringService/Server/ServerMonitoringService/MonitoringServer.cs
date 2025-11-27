using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using SharedLibraries;

namespace ServerMonitoringService
{
    public class MonitoringServer
    {
        List<Thread> threadList = new();
        private readonly JsonSerializerOptions jsonOptions;
        bool isRunning = true;


        public MonitoringServer()
        {
            jsonOptions = new JsonSerializerOptions
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
            TcpListener tcpListener = new TcpListener(IPAddress.Any, 6942);
            tcpListener.Start();
            Console.WriteLine("Monitoring Server started on Port 6942");

            while (isRunning)
            {
                try
                {
                    TcpClient client = tcpListener.AcceptTcpClient();

                    Thread thread = new(ClientHandler);
                    thread.Start(client);
                    threadList.Add(thread);
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
                while (isRunning && client.Connected)
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

                    try
                    {
                        var dataMessage = JsonSerializer.Deserialize<MonitoringMessage>(jsonString, jsonOptions);

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
            isRunning = false;
            Console.WriteLine("Server is shutting down...");
        }
    }
}
