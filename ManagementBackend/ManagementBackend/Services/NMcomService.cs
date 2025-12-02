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
        private const int HeaderSize = 4; // 1 Byte Version + 3 Bytes Länge

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

        private async Task ReadMessage(NetworkStream stream)
        {
            // Puffer zum Halten des Headers (Version + Länge)
            byte[] headerBuffer = new byte[HeaderSize];

            // Sicherstellen, dass die vollen 4 Bytes für den Header gelesen werden
            if (await ReadFullyAsync(stream, headerBuffer, HeaderSize) != HeaderSize)
            {
                // Fehler beim Lesen des Headers (z. B. Verbindung geschlossen)
                return;
            }

            // 1. Protokollversion extrahieren
            byte version = headerBuffer[0];

            // 2. Nachrichtenlänge extrahieren (3 Bytes)
            // Wir verwenden BitConverter, um die 3 Bytes in eine 32-Bit-Zahl umzuwandeln.
            // Beachten Sie, dass die 3 Bytes möglicherweise in einen 4-Byte-Buffer kopiert werden müssen,
            // um BitConverter zu verwenden, oder Sie können Bit-Shifting nutzen.

            // Beispiel mit Bit-Shifting (Endianness beachten!)
            int messageLength = (headerBuffer[1] << 16) | (headerBuffer[2] << 8) | headerBuffer[3];

            // ... weiter zur Verarbeitung

            Console.WriteLine($"Protocol Version: {version}, Message Length: {messageLength} bytes");

            // 3. Den eigentlichen Nachrichten-Body lesen
            if (messageLength > 0)
            {
                byte[] messageBuffer = new byte[messageLength];
                if (await ReadFullyAsync(stream, messageBuffer, messageLength) == messageLength)
                {
                    ProcessMessage(version, messageBuffer);
                }
            }
        }

        /// <summary>Liest garantiert die angeforderte Anzahl von Bytes aus dem Stream, es sei denn, der Stream endet.</summary>
        private async Task<int> ReadFullyAsync(Stream stream, byte[] buffer, int count)
        {
            int totalBytesRead = 0;
            while (totalBytesRead < count)
            {
                int bytesRead = await stream.ReadAsync(buffer, totalBytesRead, count - totalBytesRead);

                if (bytesRead == 0) // Stream-Ende erreicht, bevor alle Bytes gelesen wurden
                    break;

                totalBytesRead += bytesRead;
            }
            return totalBytesRead;
        }

        private void ProcessMessage(byte version, byte[] messageData)
        {
            // Hier die eigentliche Verarbeitung der Nachricht durchführen
            string message = System.Text.Encoding.UTF8.GetString(messageData);
            Console.WriteLine($"Processed message (Version {version}): {message}");
        }
    }
}
