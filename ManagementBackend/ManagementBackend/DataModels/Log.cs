namespace ManagementBackend.DataModels
{
    public class Log
    {
        public Guid Id { get; set; }

        public Guid NodeId { get; set; }

        public double RamUsage { get; set; }

        public double CpuUsage { get; set; }

        public double NetworkUsage { get; set; }

        public DateTime Timestamp { get; set; }
    }
}
