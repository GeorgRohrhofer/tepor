using System.Net;
using System.Net.Sockets;
using Microsoft.Extensions.Hosting;

namespace ManagementBackend.Services
{
    public class NMcomService
    {
        private readonly TcpListener _listener;
        private const int TcpPort = 12345;
        private const byte ProtocolVersion = 0x01;

        public NMcomService()
        {
            _listener = new TcpListener(IPAddress.Any, TcpPort);
        }

        public Task StartAsync()
        {
            _listener.Start();
            _ = ListenForConnectionsAsync();

            return Task.CompletedTask;
        }

        public Task StoptAsync()
        {
            _listener.Stop();

            return Task.CompletedTask;
        }

        private async Task ListenForConnectionsAsync()
        {
            try
            {
                while (true)
                {
                    var socket = await _listener.AcceptSocketAsync();  // Accept an incoming client socket
                    _ = HandleConnection(socket);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Wait for Socket Error: " + ex);
            }
            finally
            {
                _listener.Stop(); // Stop listening when loop finishes
            }
        }

        private async Task HandleConnection(Socket socket)
        {
            var stream = new NetworkStream(socket);

            try
            {
                while (socket.Connected)
                {

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Network Stream Error: " + ex);
            }
            finally
            {
                stream.Close();
                socket.Close();
            }
        }
    }
}
