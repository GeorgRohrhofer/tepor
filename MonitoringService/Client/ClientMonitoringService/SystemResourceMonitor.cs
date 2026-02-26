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
        private static Dictionary<string, (long rx, long tx, DateTime time)> _prevNetworkStats = new();

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
            static (long idle, long total) ReadStat()
            {
                var parts = File.ReadLines("/proc/stat").First()
                                .Split(' ', StringSplitOptions.RemoveEmptyEntries);
                // parts[0] = "cpu", [1]=user [2]=nice [3]=system [4]=idle [5]=iowait [6]=irq [7]=softirq [8]=steal
                long idle = long.Parse(parts[4]) + long.Parse(parts[5]); // idle + iowait
                long total = parts.Skip(1).Take(8).Select(long.Parse).Sum();
                return (idle, total);
            }

            var (idle1, total1) = ReadStat();
            Thread.Sleep(250);
            var (idle2, total2) = ReadStat();

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
                throw new ArgumentException("No network interfaces found");

            // Priority: Interface with most traffic 
            string? selected = _networkInterfaces
              .Where(i => i != "lo")
              .OrderByDescending(i => {
                  string rxPath = $"/sys/class/net/{i}/statistics/rx_bytes";
                  return File.Exists(rxPath) ? long.Parse(File.ReadAllText(rxPath).Trim()) : 0;
                  })
              .FirstOrDefault(); 

            if (selected == null)
                throw new ArgumentException("No network interfaces found");

            return GetNetworkUsageForInterface(selected);
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
            DateTime now = DateTime.UtcNow;

            if (!_prevNetworkStats.TryGetValue(iface, out var prev))
            {
                _prevNetworkStats[iface] = (rx, tx, now);
                return (0, 0);
            }

            double elapsed = (now - prev.time).TotalSeconds;
            if (elapsed <= 0)
                return (0, 0);

            long rxDelta = (long)((rx - prev.rx) / elapsed);
            long txDelta = (long)((tx - prev.tx) / elapsed);

            _prevNetworkStats[iface] = (rx, tx, now);

            return (rxDelta, txDelta);
        }

        static List<string> GetNetworkInterfaces()
        {
            string netClassPath = "/sys/class/net";
            List<string> interfaces = new List<string>();
            if (Directory.Exists(netClassPath))
            {
                interfaces = Directory.GetDirectories("/sys/class/net/")
                  .Select(Path.GetFileName)
                  .Where(i => i != null && i != "lo")
                  .ToList()!;
            }
            return interfaces;
        }
    }
}
