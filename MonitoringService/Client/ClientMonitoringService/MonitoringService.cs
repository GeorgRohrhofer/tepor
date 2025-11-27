using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ClientMonitoringService
{
    public class MonitoringService
    {
        private SystemResourceMonitor systemResourceMonitor;
        private DataTransmitter dataTransmitter;
        private ServerConnection serverConnection;
        private bool isRunning;

        public MonitoringService(string serverHost, int serverPort)
        {
            throw new System.NotImplementedException();
        }

        public void Start()
        {
            throw new System.NotImplementedException();
        }

        public void Stop()
        {
            throw new System.NotImplementedException();
        }

        public void MonitorAndSend()
        {
            throw new System.NotImplementedException();
        }
    }
}