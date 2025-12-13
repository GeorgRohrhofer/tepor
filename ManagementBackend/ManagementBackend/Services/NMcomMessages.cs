using System.Text.Json;

namespace ManagementBackend.Services
{
    public class NMcomMessages
    {
        private const byte ProtocolVersion = 0x01;

        public static byte[] CreateMessage(NMPMessageBase message)
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
    }

    public class NMPMessageBase
    {
        public string type { get; set; }
    }

    public class NMPMessage<T> : NMPMessageBase
    {
        public T data { get; set; }

        public NMPMessage(string type, T data)
        {
            this.type = type;
            this.data = data;
        }
    }

    // Server -> Client
    public class NMPquitMessage : NMPMessageBase
    {
        public NMPquitMessage()
        {
            this.type = "QUIT";
        }
    }

    public class HELORespData
    {
        public Guid active_id { get; set; }
    }

    public class ServerCreateData
    {
        public string world_id { get; set; }
        public string config { get; set; }
    }

    public class ServerStartData
    {
        public string world_id { get; set; }
    }

    public class ServerStopData
    {
        public string world_id { get; set; }
    }

    public class ServerRestartData
    {
        public string world_id { get; set; }
    }

    public class ServerDeleteData
    {
        public string world_id { get; set; }
    }

    public class UnsupportedVersionData
    {
        public string message { get; set; }
        public string current_version { get; set; }
    }

    public class  ErrorData
    {
        public string message { get; set; }
    }

    // Client -> Server
    public class HELOReqData
    {
        public Guid previous_id { get; set; }
    }

    public class WorldSavedData
    {
        public string world_id { get; set; }
        public string hash { get; set; }
    }
}
