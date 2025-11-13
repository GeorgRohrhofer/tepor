using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Diagnostics;

namespace ClientMonitoringService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            SystemResourceMonitor resourceMonitor = new SystemResourceMonitor();
            resourceMonitor.Monitor();
        }
    }
}
