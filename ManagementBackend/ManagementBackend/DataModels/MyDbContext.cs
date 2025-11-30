using Microsoft.EntityFrameworkCore;

namespace ManagementBackend.DataModels
{
    public class MyDbContext : DbContext
    {
        public DbSet<World> Worlds { get; set; }
        public DbSet<WorldStore> WorldStores { get; set; }
        public DbSet<Log> Logs { get; set; }
        public DbSet<Node> Nodes { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
            => optionsBuilder.UseSqlite(@"Data Source=C:\temp\Demo.db");
    }
}
