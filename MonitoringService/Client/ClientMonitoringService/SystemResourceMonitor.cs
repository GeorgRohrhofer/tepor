using SharedLibraries;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.NetworkInformation;
using System.Text;
using static System.Net.Mime.MediaTypeNames;

namespace ClientMonitoringService
{
    public class SystemResourceMonitor
    {
        private static List<string>? _networkInterfaces;

        public SystemResourceMonitor()
        {
            _networkInterfaces = GetNetworkInterfaces();

            if (_networkInterfaces.Count == 0)
            {
                throw new ArgumentException("No network interfaces found");
            }
        }

        /// <summary>
        /// Monitors system resources and returns a MonitoringMessage.
        /// </summary>
        /// <returns>CPU usage in percentage, Memory usage in percentage, Disk usage in percentage, Network usage (rx, tx) in bytes</returns>
        public MonitoringMessage Monitor()
        {
            MonitoringMessage message = new MonitoringMessage();

            message.CpuUsage = GetCpuUsage();
            message.MemoryUsage = GetMemoryUsage();
            message.DiskUsage = GetDiskUsage("/");
            var (rx, tx) = GetNetworkUsage();
            message.NetworkUsage = new double[] { rx, tx };

            return message;
        }

        public MonitoringMessage Monitor(string networkInterface)
        {
            MonitoringMessage message = new MonitoringMessage();

            message.CpuUsage = GetCpuUsage();
            message.MemoryUsage = GetMemoryUsage();
            message.DiskUsage = GetDiskUsage("/");
            var (rx, tx) = GetNetworkUsage(networkInterface);
            message.NetworkUsage = new double[] { rx, tx };

            return message;
        }

        /// <summary>
        /// Get CPU usage percentage.
        /// </summary>
        /// <returns></returns>
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

        /// <summary>
        /// Get Memory usage percentage.
        /// </summary>
        /// <returns></returns>
        static double GetMemoryUsage()
        {
            var lines = File.ReadAllLines("/proc/meminfo");
            long memTotal = long.Parse(lines.First(l => l.StartsWith("MemTotal")).Split(' ', StringSplitOptions.RemoveEmptyEntries)[1]);
            long memAvailable = long.Parse(lines.First(l => l.StartsWith("MemAvailable")).Split(' ', StringSplitOptions.RemoveEmptyEntries)[1]);
            return 100.0 * (memTotal - memAvailable) / memTotal;
        }

        /// <summary>
        /// Get Disk usage percentage for the specified path.
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        static double GetDiskUsage(string path)
        {
            var drive = new DriveInfo(path);
            double used = drive.TotalSize - drive.AvailableFreeSpace;
            return 100.0 * used / drive.TotalSize;
        }

        /// <summary>
        /// Gets Network usage in bytes. Automatically detects available interfaces with preference for ethernet.
        /// </summary>
        /// <returns>Tuple of (rx, tx) in bytes</returns>
        static (long rx, long tx) GetNetworkUsage()
        {

            if (_networkInterfaces == null)
            {
                throw new ArgumentException("No network interfaces found");
            }

            List<(long, long)> ethNetworks = new List<(long, long)>();
            foreach (string iface in _networkInterfaces)
            {
                if (iface.StartsWith("eth") || iface.StartsWith("en"))
                {
                    ethNetworks.Add(GetNetworkUsageForInterface(iface));
                }
            }

            foreach ((long, long) network in ethNetworks)
            {
                if (!(network.Item1 == 0) && !(network.Item2 == 0))
                    return network;
            }

            List<(long, long)> allNetworks = new List<(long, long)>();
            foreach (string iface in _networkInterfaces)
            {
                allNetworks.Add(GetNetworkUsageForInterface(iface));
            }

            foreach ((long, long) network in allNetworks)
            {
                if (!(network.Item1 == 0) && !(network.Item2 == 0))
                    return network;
            }

            throw new ArgumentException("No valid network interface");
        }

        static (long rx, long tx) GetNetworkUsage(string networkInterface)
        {
            return GetNetworkUsageForInterface(networkInterface);
        }

        /// <summary>
        /// Gets Network usage in bytes for a specific interface.
        /// </summary>
        /// <param name="iface">Interface name</param>
        /// <returns>Tuple of (rx, tx) in bytes</returns>
        static (long rx, long tx) GetNetworkUsageForInterface(string iface)
        {
            string rxPath = $"/sys/class/net/{iface}/statistics/rx_bytes";
            string txPath = $"/sys/class/net/{iface}/statistics/tx_bytes";

            if (!File.Exists(rxPath) || !File.Exists(txPath))
                return (0, 0);

            long rx = long.Parse(File.ReadAllText(rxPath).Trim());
            long tx = long.Parse(File.ReadAllText(txPath).Trim());
            return (rx, tx);
        }

        static List<string> GetNetworkInterfaces()
        {
            string netClassPath = "/sys/class/net";
            List<string> interfaces = new List<string>();
            if (Directory.Exists(netClassPath))
            {
                interfaces = Directory.GetDirectories(netClassPath)
                    .Select(d => new DirectoryInfo(d).Name)
                    .Where(name => !name.Equals("lo", StringComparison.OrdinalIgnoreCase))
                    .ToList();
            }
            return interfaces;
        }
    }
}