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
        private string? _networkInterface = null;

        public MonitoringService(string serverHost, int serverPort, string nodeID)
        {
            _systemResourceMonitor = new SystemResourceMonitor();
            _dataTransmitter = new DataTransmitter(serverHost, serverPort);
            _isRunning = false;
            _nodeID = nodeID;
        }

        public MonitoringService(string serverHost, int serverPort, string nodeID, string networkInterface)
        {
            _systemResourceMonitor = new SystemResourceMonitor();
            _dataTransmitter = new DataTransmitter(serverHost, serverPort);
            _isRunning = false;
            _nodeID = nodeID;
            _networkInterface = networkInterface;
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

        private void _MonitorAndSend()
        {
            while (_isRunning)
            {
                MonitoringMessage message;
                if (_networkInterface == null)
                {
                    message = _systemResourceMonitor.Monitor();
                }
                else
                {
                    message = _systemResourceMonitor.Monitor(_networkInterface);
                }

                message.NodeID = _nodeID;

                bool success = _dataTransmitter.SendSystemData(message);
                if (!success)
                {
                    Console.WriteLine("Failed to send monitoring data to server.");
                }
                Thread.Sleep(4000);
            }
        }
    }
}