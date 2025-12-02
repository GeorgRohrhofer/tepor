using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ClientMonitoringService
{
    public class ServerConnection
    {
        private System.Net.IPAddress _serverHost;
        private int _serverPort;

        public ServerConnection(string serverHost, int serverPort)
        {
            _serverHost = System.Net.IPAddress.Parse(serverHost);
            _serverPort = serverPort;
        }

        public System.Net.IPAddress ServerHost
        {
            get
            {
                return _serverHost;
            }
            set
            {
                if (value == null)
                {
                    throw new ArgumentNullException(nameof(value), "Server host cannot be null.");
                }

                _serverHost = value;
            }
        }

        public int ServerPort
        {
            get
            {
                return _serverPort; 
            }
            set
            {
                _serverPort = value;
            }
        }
    }
}