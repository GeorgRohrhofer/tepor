namespace ManagementBackend.DataModels
{
    public class World
    {
        public Guid Id { get; set; }

        public string Name { get; set; }

        public string Hash { get; set; }

        public string Config { get; set; }

        public Guid OwnerId { get; set; }
    }
}
