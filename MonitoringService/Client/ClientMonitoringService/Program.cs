using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Diagnostics;
using SharedLibraries;
using System.Text.Json;
using System.Net.Sockets;
using System.Text;

namespace ClientMonitoringService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            //SystemResourceMonitor resourceMonitor = new SystemResourceMonitor();
            //resourceMonitor.Monitor();


            MonitoringMessage message = new MonitoringMessage() 
            { 
                    NodeID = "abc123",
                    MemoryUsage = 30,
                    CpuUsage = 40,
                    DiskUsage = 69,
                    NetworkUsage = [3000, 1500]    
            };

            TcpClient client = new();
            var ipaddress = System.Net.IPAddress.Parse("127.0.0.1");
            client.Connect(ipaddress, 6942);
            NetworkStream stream = client.GetStream();
            byte[] messageBytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

            while (true)
            {
                stream.Write(messageBytes);
                Thread.Sleep(2000);
            }

        }
    }
}
