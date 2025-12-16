namespace ManagementBackend.DataModels
{
    public class WorldStore
    {
        public Guid Id { get; set; }

        public Guid WorldId { get; set; }

        public Guid RunningNodeId { get; set; }

        public List<Guid> BackUpNodeIds { get; set; }
    }
}
