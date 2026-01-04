# Start ServerMonitoringService Server

## Prerequisites
- .NET 8 SDK installed  
- Network access for the chosen ports (defaults: `6942` for clients, `6943` for API)  
- Permission to bind to the chosen ports

## Command-line options
- `--clientport` (optional) — port where the server accepts client/node connections (default: `6942`)  
- `--apiport` (optional) — port for the HTTP API that returns current resource data (default: `6943`)

## Examples
- Run from source: 
  `dotnet run --project ServerMonitoringService -- --clientport 6942 --apiport 6943`
- Run published binary: 
  `ServerMonitoringService.exe --clientport 6942 --apiport 6943`


## Stopping
- Stop with `Ctrl+C` in the terminal; when deployed as a service use the platform service controls.

## Troubleshooting
- Invalid parameters are written to `stderr` — check flags and re-run.  
- If a port is already in use: check with `netstat` / `ss` / `Get-NetTCPConnection` and choose a free port.  
- Verify firewall/NAT rules allow incoming connections on the chosen ports.  
- Check .NET runtime with `dotnet --info`.  
- For connectivity issues: test with `telnet <host> <port>` or `Test-NetConnection` and inspect application logs.
