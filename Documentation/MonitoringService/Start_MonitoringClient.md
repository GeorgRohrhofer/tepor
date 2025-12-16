# Start ClientMonitoringService Client

## Prerequisites
- .NET 8 SDK
- Network access to the monitoring server

## Command-line options
- `--ipaddress` (required) — monitoring server IP
- `--port` (required) — monitoring server port
- `--nodeid` (required) — client/node ID
- `--networkinterface` (optional) — specific network interface

## Examples
- Run from source:
  `dotnet run --project ClientMonitoringService -- --ipaddress 192.168.1.10 --port 6942 --nodeid node-01`
- Run published binary:
  `ClientMonitoringService.exe --ipaddress 192.168.1.10 --port 6942 --nodeid node-01 --networkinterface eth0`

## Troubleshooting
- Invalid parameters are written to stderr.
- Verify server reachability and firewall/port rules.
