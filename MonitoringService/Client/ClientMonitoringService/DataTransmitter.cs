using SharedLibraries;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;

namespace ClientMonitoringService
{
    public class DataTransmitter
    {
        private ServerConnection _connection;
        private NetworkStream _stream;

        public DataTransmitter(string ipAddress, int port)
        {
            TcpClient client = new();
            _connection = new ServerConnection(ipAddress, port);
            client.Connect(_connection.ServerHost, _connection.ServerPort);
            _stream = client.GetStream();
            if (_stream == null)
            {
                throw new IOException("Failed to obtain network stream from TCP client.");
            }
        }

        public bool SendSystemData(MonitoringMessage message)
        { 
            byte[] messageBytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));
            byte versionNumber = 1;
            byte[] senderMessageBytes = new byte[messageBytes.Length + 1];
            senderMessageBytes[0] = versionNumber;
            Array.Copy(messageBytes, 0, senderMessageBytes, 1, messageBytes.Length);
            
            try 
            {
                _stream.Write(senderMessageBytes);
            }
            catch (IOException)
            {
                return false;
            }
            return true;
        }
    }
}