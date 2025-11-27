namespace ServerMonitoringService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            MonitoringServer monitoringServer = new MonitoringServer();
            monitoringServer.Start();


        }
    }
}
