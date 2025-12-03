using System.CommandLine;
using System.CommandLine.Parsing;
namespace ServerMonitoringService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Option<int> clientPortOption = new("--clientport")
            {
                Description = "The Port the service will be listening to.",
                DefaultValueFactory = _ => 6942
            };
            Option<int> apiPortOption = new("--apiport")
            {
                Description = "The Port for the api. Request returns current resource data on all nodes.",
                DefaultValueFactory = _ => 6943
            };


            RootCommand rootCommand = new("Start Server Monitoring Service");
            rootCommand.Options.Add(clientPortOption);
            rootCommand.Options.Add(apiPortOption);

            ParseResult parseResult = rootCommand.Parse(args);
            if (parseResult.Errors.Count == 0 && parseResult.GetValue(clientPortOption) is int clientPort && parseResult.GetValue(apiPortOption) is int apiPort)
            {
                MonitoringServer monitoringServer = new(clientPort);
                monitoringServer.Start();
                MonitoringServiceAPI monitoringServiceAPI = new(monitoringServer);
                monitoringServiceAPI.Start(apiPort);

                return;
            }
            foreach (ParseError parseError in parseResult.Errors)
            {
                Console.Error.WriteLine(parseError.Message);
            }
        }
    }
}
