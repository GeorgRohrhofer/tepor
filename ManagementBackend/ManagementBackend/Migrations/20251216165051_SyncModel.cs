using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ManagementBackend.Migrations
{
    /// <inheritdoc />
    public partial class SyncModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // WorldStores.WorldId
            migrationBuilder.Sql(
                @"ALTER TABLE ""WorldStores""
          ALTER COLUMN ""WorldId"" TYPE uuid
          USING ""WorldId""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "WorldId",
            //    table: "WorldStores",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // WorldStores.RunningNodeId
            migrationBuilder.Sql(
                @"ALTER TABLE ""WorldStores""
          ALTER COLUMN ""RunningNodeId"" TYPE uuid
          USING ""RunningNodeId""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "RunningNodeId",
            //    table: "WorldStores",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // WorldStores.BackUpNodeIds: TEXT -> uuid[] is not auto-castable either
            migrationBuilder.Sql(
                @"ALTER TABLE ""WorldStores""
          ALTER COLUMN ""BackUpNodeIds"" TYPE uuid[]
          USING string_to_array(""BackUpNodeIds"", ',')::uuid[];");

            //migrationBuilder.AlterColumn<List<Guid>>(
            //    name: "BackUpNodeIds",
            //    table: "WorldStores",
            //    type: "uuid[]",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // WorldStores.Id
            migrationBuilder.Sql(
                @"ALTER TABLE ""WorldStores""
          ALTER COLUMN ""Id"" TYPE uuid
          USING ""Id""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "Id",
            //    table: "WorldStores",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // Worlds.OwnerId
            migrationBuilder.Sql(
                @"ALTER TABLE ""Worlds""
          ALTER COLUMN ""OwnerId"" TYPE uuid
          USING ""OwnerId""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "OwnerId",
            //    table: "Worlds",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // Worlds.Id
            migrationBuilder.Sql(
                @"ALTER TABLE ""Worlds""
          ALTER COLUMN ""Id"" TYPE uuid
          USING ""Id""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "Id",
            //    table: "Worlds",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // Nodes.Id
            migrationBuilder.Sql(
                @"ALTER TABLE ""Nodes""
          ALTER COLUMN ""Id"" TYPE uuid
          USING ""Id""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "Id",
            //    table: "Nodes",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // Logs.NodeId
            migrationBuilder.Sql(
                @"ALTER TABLE ""Logs""
          ALTER COLUMN ""NodeId"" TYPE uuid
          USING ""NodeId""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "NodeId",
            //    table: "Logs",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // Logs.Id
            migrationBuilder.Sql(
                @"ALTER TABLE ""Logs""
          ALTER COLUMN ""Id"" TYPE uuid
          USING ""Id""::uuid;");

            //migrationBuilder.AlterColumn<Guid>(
            //    name: "Id",
            //    table: "Logs",
            //    type: "uuid",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            // The remaining changes (float -> double, TEXT -> text, etc.) are safe:
            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Worlds",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "TEXT");

            migrationBuilder.AlterColumn<string>(
                name: "Hash",
                table: "Worlds",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "TEXT");

            migrationBuilder.AlterColumn<string>(
                name: "Config",
                table: "Worlds",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "TEXT");

            migrationBuilder.AlterColumn<double>(
                name: "Ram",
                table: "Nodes",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "REAL");

            migrationBuilder.AlterColumn<double>(
                name: "Cpu",
                table: "Nodes",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "REAL");

            migrationBuilder.Sql(
                @"ALTER TABLE ""Logs""
                  ALTER COLUMN ""Timestamp"" TYPE timestamp with time zone
                  USING ""Timestamp""::timestamp with time zone;");

            //migrationBuilder.AlterColumn<DateTime>(
            //    name: "Timestamp",
            //    table: "Logs",
            //    type: "timestamp with time zone",
            //    nullable: false,
            //    oldClrType: typeof(string),
            //    oldType: "TEXT");

            migrationBuilder.AlterColumn<double>(
                name: "RamUsage",
                table: "Logs",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "REAL");

            migrationBuilder.AlterColumn<double>(
                name: "NetworkUsage",
                table: "Logs",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "REAL");

            migrationBuilder.AlterColumn<double>(
                name: "CpuUsage",
                table: "Logs",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "REAL");
        }
    }
}
