using System.CommandLine;
using System.CommandLine.Parsing;
namespace ServerMonitoringService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Option<int> portOption = new("--port")
            {
                Description = "The Port the service will be listening to.",
                DefaultValueFactory = _ => 6942
            };

            RootCommand rootCommand = new("Start Server Monitoring Service");
            rootCommand.Options.Add(portOption);

            ParseResult parseResult = rootCommand.Parse(args);
            if (parseResult.Errors.Count == 0 && parseResult.GetValue(portOption) is int port)
            {

                MonitoringServer monitoringServer = new MonitoringServer(port);
                monitoringServer.Start();
                return;
            }
            foreach (ParseError parseError in parseResult.Errors)
            {
                Console.Error.WriteLine(parseError.Message);
            }
        }
    }
}
