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
            Option<string?> networkinterfaceOption = new("--networkinterface")
            {
                Description = "The ID of the Node the data is of.",
                Required = false,
            };

            RootCommand rootCommand = new("Start Client Monitoring Service");
            rootCommand.Options.Add(ipaddressOption);
            rootCommand.Options.Add(portOption);
            rootCommand.Options.Add(nodeidOption);
            rootCommand.Options.Add(networkinterfaceOption);

            ParseResult parseResult = rootCommand.Parse(args);

            string? ip = parseResult.GetValue(ipaddressOption);
            int i = parseResult.GetValue(portOption);
            string? id = parseResult.GetValue(nodeidOption);
            string? networkif = parseResult.GetValue(networkinterfaceOption);

            if (parseResult.Errors.Count == 0)
            {
                if (networkif == null)
                {
                    MonitoringService monitoringService = new MonitoringService(ip!, i, id!);
                    monitoringService.Start();
                }
                else
                {
                    MonitoringService monitoringService = new MonitoringService(ip!, i, id!, networkif);
                    monitoringService.Start();
                }
                return;
            }
            foreach (ParseError parseError in parseResult.Errors)
            {
                Console.Error.WriteLine(parseError.Message);
            }
        }
    }
}
