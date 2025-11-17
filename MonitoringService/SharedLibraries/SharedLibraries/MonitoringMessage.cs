namespace SharedLibraries
{
    public class MonitoringMessage
    {
        public string MemoryUsage { get; set; } = string.Empty;
        public string CpuUsage { get; set; } = string.Empty;
        public string DiskUsage { get; set; } = string.Empty;
        public string NetworkUsage { get; set; } = string.Empty;
    }
}
