using ManagementBackend.DataModels;
using ManagementBackend.resources;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

namespace ManagementBackend
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
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

            builder.Services.AddControllers();
            // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
            builder.Services.AddOpenApi();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // Add DiscordMessageSender
            var discordBotIp = builder.Configuration.GetSection("DiscordBotIp").Get<string>();
            if (discordBotIp == null)
                throw new Exception("DiscordBotIp section is missing in configuration.");
            var discordMessageSender = new DiscordMessageSender(discordBotIp);
            builder.Services.AddSingleton(discordMessageSender);

            // Add DbContext
            var dbContext = new MyDbContext();
            builder.Services.AddSingleton(dbContext);

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();
            app.UseAuthorization();
            app.MapControllers();

            app.Run();
        }
    }
}
