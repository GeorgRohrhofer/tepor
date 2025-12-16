using Microsoft.EntityFrameworkCore;

namespace ManagementBackend.DataModels
{
    public class MyDbContext : DbContext
    {
        public DbSet<World> Worlds { get; set; }
        public DbSet<WorldStore> WorldStores { get; set; }
        public DbSet<Log> Logs { get; set; }
        public DbSet<Node> Nodes { get; set; }

        public MyDbContext(DbContextOptions<MyDbContext> options) : base(options) { }
    }
}
