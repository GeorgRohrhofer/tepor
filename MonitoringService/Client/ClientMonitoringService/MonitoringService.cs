using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SharedLibraries;

namespace ClientMonitoringService
{
    public class MonitoringService
    {
        private SystemResourceMonitor _systemResourceMonitor;
        private DataTransmitter _dataTransmitter;
        private bool _isRunning;
        private string _nodeID;

        public MonitoringService(string serverHost, int serverPort, string nodeID)
        {
            _systemResourceMonitor = new SystemResourceMonitor();
            _dataTransmitter = new DataTransmitter(serverHost, serverPort);
            _isRunning = false;
            _nodeID = nodeID;
        }

        public void Start()
        {
            _isRunning = true;
            _MonitorAndSend();
        }

        public void Stop()
        {
            _isRunning = false;
        }

        public void _MonitorAndSend()
        {
            while (_isRunning)
            {
                MonitoringMessage message = _systemResourceMonitor.Monitor();
                message.NodeID = _nodeID;

                bool success = _dataTransmitter.SendSystemData(message);
                if (!success)
                {
                    // Handle transmission failure (e.g., log error, retry, etc.)
                }
                Thread.Sleep(4000);
            }
        }
    }
}