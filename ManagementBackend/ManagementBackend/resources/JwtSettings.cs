namespace ManagementBackend.resources
{
    public class JwtSettings
    {
        public string Authority { get; set; } = string.Empty;
        public string ValidIssuer { get; set; } = string.Empty;
        public string[] ValidAudiences { get; set; } = [];
        public bool RequireHttpsMetadata { get; set; }
    }
}
