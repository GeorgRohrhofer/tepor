using SharedLibraries;
using System;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Threading;

namespace ClientMonitoringService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Option<string> ipaddressOption = new("--ipaddress")
            {
                Description = "The IP Address of the Monitoring Server, the messege will be sent to.",
                Required = true,
            };
            Option<int> portOption = new("--port")
            {
                Description = "The Port on the Monitoring Server, the messege will be sent to.",
                Required = true,
            };
            Option<string> nodeidOption = new("--nodeid")
            {
                Description = "The ID of the Node the data is of.",
                Required = true,
            };

            RootCommand rootCommand = new("Sample app for System.CommandLine");
            rootCommand.Options.Add(ipaddressOption);
            rootCommand.Options.Add(portOption);
            rootCommand.Options.Add(nodeidOption);

            ParseResult parseResult = rootCommand.Parse(args);
            if (parseResult.Errors.Count == 0 && parseResult.GetValue(ipaddressOption) is string ip && parseResult.GetValue(portOption) is int i && parseResult.GetValue(nodeidOption) is string id)
            {
                MonitoringService monitoringService = new MonitoringService(ip, i, id);
                monitoringService.Start();
                return;
            }
            foreach (ParseError parseError in parseResult.Errors)
            {
                Console.Error.WriteLine(parseError.Message);
            }
        }
    }
}
