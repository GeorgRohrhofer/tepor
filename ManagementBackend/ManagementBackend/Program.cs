using ManagementBackend.DataModels;
using ManagementBackend.resources;
using ManagementBackend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;

namespace ManagementBackend
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add DbContext
            builder.Services.AddDbContext<MyDbContext>(options =>
            {
                var cs = builder.Configuration.GetConnectionString("DefaultDbConnection");
                options.UseNpgsql(cs);
            });

            // Add CORS policy to allow all origins, headers, and methods.
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", policy =>
                {
                    policy
                        .AllowAnyOrigin()
                        .AllowAnyHeader()
                        .AllowAnyMethod();
                });
            });

            // Add Keycloak Auth.
            var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
            if (jwtSettings == null)
                throw new Exception("JwtSettings section is missing in configuration.");

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            })
                .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
                {
                    options.Authority = jwtSettings.Authority;
                    options.RequireHttpsMetadata = jwtSettings.RequireHttpsMetadata;

                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidIssuer = jwtSettings.ValidIssuer,
                        ValidateAudience = true,
                        ValidAudiences = jwtSettings.ValidAudiences,
                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true
                    };
                });

            // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
            builder.Services.AddControllers();
            builder.Services.AddOpenApi();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // Add DiscordMessageSender
            var discordBotIp = builder.Configuration.GetSection("DiscordBotIp").Get<string>();
            if (discordBotIp == null)
                throw new Exception("DiscordBotIp section is missing in configuration.");
            var discordBotDefaultUserId = builder.Configuration.GetSection("DiscordBotDefaultUserId").Get<string>();
            if (discordBotDefaultUserId == null)
                throw new Exception("DiscordBotDefaultUserId section is missing in configuration.");
            var discordMessageSender = new DiscordMessageSender(discordBotIp, discordBotDefaultUserId);
            builder.Services.AddSingleton(discordMessageSender);

            // MonitoringComService as singleton
            builder.Services.AddSingleton<MonitoringComService>(sp =>
            {
                var monitorIp = builder.Configuration.GetSection("MonitoringIp").Get<string>()
                               ?? throw new Exception("MonitoringIp section is missing in configuration.");

                var scopeFactory = sp.GetRequiredService<IServiceScopeFactory>();

                return new MonitoringComService(monitorIp, scopeFactory);
            });

            // Tcp Socket
            builder.Services.AddSingleton<NMcomService>();
            builder.Services.AddHostedService(provider => provider.GetRequiredService<NMcomService>());

            var app = builder.Build();

            // Ensure Db is created and migrated
            using (var scope = app.Services.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<MyDbContext>();
                db.Database.Migrate();
            }

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseCors("AllowAll");
            app.UseHttpsRedirection();
            app.UseAuthorization();
            app.MapControllers();

            app.Run();
        }
    }
}
