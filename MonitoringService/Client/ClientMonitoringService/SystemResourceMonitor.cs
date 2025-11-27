using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using SharedLibraries;

namespace ClientMonitoringService
{
    public class SystemResourceMonitor
    {
        public void Monitor()
        {
            Console.WriteLine("=== Linux System Resource Monitor ===\n");

            while (true)
            {
                double cpuUsage = GetCpuUsage();
                double memoryUsage = GetMemoryUsage();
                double diskUsage = GetDiskUsage("/");
                var (rx, tx) = GetNetworkUsage("eth0");

                Console.Clear();
                Console.WriteLine("=== Linux System Resource Monitor ===");
                Console.WriteLine($"Memory Usage:    {memoryUsage:F2}%");
                Console.WriteLine($"CPU Usage:       {cpuUsage:F2}%");
                Console.WriteLine($"Disk Usage (/):  {diskUsage:F2}%");
                Console.WriteLine($"Network (eth0):  RX={rx / 1024:F1} KB  TX={tx / 1024:F1} KB");

                Thread.Sleep(4000);
            }
        }

        static double GetCpuUsage()
        {
            string[] cpuLine1 = File.ReadLines("/proc/stat").First().Split(' ', StringSplitOptions.RemoveEmptyEntries);
            long idle1 = long.Parse(cpuLine1[4]);
            long total1 = cpuLine1.Skip(1).Select(long.Parse).Sum();

            Thread.Sleep(500);

            string[] cpuLine2 = File.ReadLines("/proc/stat").First().Split(' ', StringSplitOptions.RemoveEmptyEntries);
            long idle2 = long.Parse(cpuLine2[4]);
            long total2 = cpuLine2.Skip(1).Select(long.Parse).Sum();

            long idleDiff = idle2 - idle1;
            long totalDiff = total2 - total1;

            return 100.0 * (1.0 - (double)idleDiff / totalDiff);
        }

        static double GetMemoryUsage()
        {
            var lines = File.ReadAllLines("/proc/meminfo");
            long memTotal = long.Parse(lines.First(l => l.StartsWith("MemTotal")).Split(' ', StringSplitOptions.RemoveEmptyEntries)[1]);
            long memAvailable = long.Parse(lines.First(l => l.StartsWith("MemAvailable")).Split(' ', StringSplitOptions.RemoveEmptyEntries)[1]);
            return 100.0 * (memTotal - memAvailable) / memTotal;
        }

        static double GetDiskUsage(string path)
        {
            var drive = new DriveInfo(path);
            double used = drive.TotalSize - drive.AvailableFreeSpace;
            return 100.0 * used / drive.TotalSize;
        }

        static (long rx, long tx) GetNetworkUsage(string iface)
        {
            string rxPath = $"/sys/class/net/{iface}/statistics/rx_bytes";
            string txPath = $"/sys/class/net/{iface}/statistics/tx_bytes";

            if (!File.Exists(rxPath) || !File.Exists(txPath))
                return (0, 0);

            long rx = long.Parse(File.ReadAllText(rxPath));
            long tx = long.Parse(File.ReadAllText(txPath));
            return (rx, tx);
        }
    }
}