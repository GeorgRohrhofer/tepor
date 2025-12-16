using System;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ManagementBackend.Services
{
    public class NMcomMessages
    {
        public const byte ProtocolVersion = 0x01;
        private const int HeaderSize = 5; // 1 Byte Version + 4 Bytes Länge

        public static byte[] CreateMessage<T>(NMPMessage<T> message)
        {
            string jsonPayload = JsonSerializer.Serialize(message);
            byte[] payloadBytes = System.Text.Encoding.UTF8.GetBytes(jsonPayload);
            int payloadLength = payloadBytes.Length;

            byte[] frame = new byte[1 + 4 + payloadLength];

            frame[0] = ProtocolVersion;

            byte[] lengthBytes = BitConverter.GetBytes(payloadLength);
            if (BitConverter.IsLittleEndian)
            {
                Array.Reverse(lengthBytes);
            }
            Array.Copy(lengthBytes, 0, frame, 1, 4);
            Array.Copy(payloadBytes, 0, frame, 5, payloadLength);

            return frame;
        }

        public static (string type, string json) ReadMessage(NetworkStream stream)
        {
            // Read Header
            byte[] headerBuffer = new byte[HeaderSize];

            ReadFully(stream, headerBuffer, HeaderSize);

            if (headerBuffer[0] != ProtocolVersion)
                return ("error_version_mismatch", string.Empty);

            int messageLength = (headerBuffer[1] << 24) | (headerBuffer[2] << 16) | (headerBuffer[3] << 8) | headerBuffer[4];

            if (messageLength <= 0)
                return ("error_empty_message", string.Empty);

            // Read Message
            byte[] messageBuffer = new byte[messageLength];

            ReadFully(stream, messageBuffer, messageLength);

            string messageJson = System.Text.Encoding.UTF8.GetString(messageBuffer);
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var baseMessage = JsonSerializer.Deserialize<NMPMessage<object>>(messageJson, options);

            if (baseMessage == null)
                return ("error_invalid_message", string.Empty);

            return (baseMessage.type, messageJson);
        }

        private static int ReadFully(Stream stream, byte[] buffer, int count)
        {
            int totalBytesRead = 0;
            while (totalBytesRead < count)
            {
                int bytesRead = stream.Read(buffer, totalBytesRead, count - totalBytesRead);

                if (bytesRead == 0) // Stream-Ende erreicht, bevor alle Bytes gelesen wurden
                    break;

                totalBytesRead += bytesRead;
            }
            return totalBytesRead;
        }
    }

    public class NMPMessage<T>
    {
        public string type { get; set; }

        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public T? data { get; set; }

        public NMPMessage() { }

        public NMPMessage(string type)
        {
            this.type = type;
            this.data = default(T);
        }

        public NMPMessage(string type, T data)
        {
            this.type = type;
            this.data = data;
        }
    }

    // Server -> Client
    public class NMPquitData
    {
    }

    public class HELORespData
    {
        public Guid active_id { get; set; }
    }

    public class ServerCreateData
    {
        public required Guid world_id { get; set; }
        public required string config { get; set; }
    }

    public class ServerStartData
    {
        public required Guid world_id { get; set; }
    }

    public class ServerStopData
    {
        public required Guid world_id { get; set; }
    }

    public class ServerRestartData
    {
        public required Guid world_id { get; set; }
    }

    public class ServerDeleteData
    {
        public required Guid world_id { get; set; }
    }

    public class UnsupportedVersionData
    {
        public required string message { get; set; }
        public required string current_version { get; set; }
    }

    public class  ErrorData
    {
        public required string message { get; set; }
    }

    // Client -> Server
    public class HELOReqData
    {
        public Guid previous_id { get; set; }
    }

    public class WorldSavedData
    {
        public required Guid world_id { get; set; }
        public required string hash { get; set; }
    }
}
