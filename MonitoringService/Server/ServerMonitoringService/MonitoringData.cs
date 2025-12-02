using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ServerMonitoringService
{
    public class MonitoringData
    {
        public double MemoryUsage { get; set; }
        public double CpuUsage { get; set; }
        public double DiskUsage { get; set; }
        public double[] NetworkUsage { get; set; } = Array.Empty<double>();
        public DateTime LastUpdated { get; set; }
        public bool StillActive {  get; set; }
    }
}