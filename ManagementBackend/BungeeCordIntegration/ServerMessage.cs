namespace BungeeCordIntegration
{
    public class ServerMessage
    {
        public required bool register { get; set; }
        public required string serverName { get; set; }
        public required string ipAddress { get; set; }
        public required int port { get; set; }
    }
}
