using System;
using Monitoring;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data.Common;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ServerMonitoringService
{
    public class MonitoringServiceAPI
    {
        private int _timeoutMilliseconds = 12000;
        private MonitoringServer _server;
        private HttpListener _listener;
        private bool _isRunning = true;

        public MonitoringServiceAPI(MonitoringServer server)
        {
            _server = server;
            _listener = new HttpListener();
        }

        private void _StartNetworkListener(int port)
        {
            _listener.Prefixes.Add($"http://*:{port}/");
            _listener.Start();
            Console.WriteLine($"HTTP Listener started on port {port}");

            Thread listenerThread = new(() => _ListenForRequests())
            {
                IsBackground = true
            };
            listenerThread.Start();
        }

        private void _ListenForRequests()
        {
            while (_isRunning)
            {
                try
                {
                    HttpListenerContext context = _listener.GetContext();
                    HttpListenerRequest request = context.Request;
                    HttpListenerResponse response = context.Response;

                    Console.WriteLine($"Request received: {request.HttpMethod} {request.RawUrl}");

                    if (request.Url?.AbsolutePath == "/monitor/all")
                    {

                        byte[] message = _CreateMessage(_server.GetClientsSnapshot(), DateTime.Now);

                        _SendMessage(message, response);
                        
                        throw new IOException("Failed to send message after multiple attempts.");
                    }
                    else
                    {
                        response.StatusCode = 404;
                        byte[] buffer = Encoding.UTF8.GetBytes("Not found");
                        response.OutputStream.Write(buffer, 0, buffer.Length);
                    }

                    response.OutputStream.Close();

                }
                catch (ObjectDisposedException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error in NetworkListener: {ex.Message}");
                }
            }
        }

        private byte[] _CreateMessage(IReadOnlyDictionary<string, MonitoringData> clients, DateTime sendTime)
        {
            foreach (var client in clients)
            {
                if ((sendTime - client.Value.LastUpdated).TotalMilliseconds > _timeoutMilliseconds)
                {
                    client.Value.StillActive = false;

                }
            }

            byte[] messageBytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(clients));
            
            return messageBytes;
        }

        private bool _SendMessage(byte[] message, HttpListenerResponse response)
        {
            try
            {
                response.ContentType = "application/json";
                response.ContentLength64 = message.Length;
                response.OutputStream.Write(message, 0, message.Length);
            }
            catch (IOException)
            {
                return false;
            }
            return true;
        }

        public void Start(int port)
        {
            _StartNetworkListener(port);
        }

        public void Stop()
        {
            _isRunning = false;
            _listener?.Stop();
            _listener?.Close();
            Console.WriteLine("API service stopped.");
        }
    }
}
