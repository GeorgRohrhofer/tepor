namespace SharedLibraries
{
    public class MonitoringMessage
    {
        public string NodeID { get; set; } = string.Empty;
        public double MemoryUsage { get; set; } 
        public double CpuUsage { get; set; }
        public double DiskUsage { get; set; }
        public double[] NetworkUsage { get; set; } = Array.Empty<double>();
    }
}
