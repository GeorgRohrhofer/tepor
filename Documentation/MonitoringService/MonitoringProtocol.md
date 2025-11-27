To monitor the individual nodes, they periodically send some sytem data to the Management Server.
They send: 
- their Node ID (string)
- Memory Usage (double - as percentage)
- Cpu Usage (double - as percentage)
- Disk Usage (double - as percentage)
- NetworkUsage (double array - [rx, tx])

```json
{
    "NodeID": "abc123",
    "MemoryUsage" : 30,
    "CpuUsage" : 40,
    "DiskUsage" : 69,
    "NetworkUsage" : [3000, 1500]
}
```
Once the Management Server does not receive this "heartbeat" in the determined time, the Node will be considered to be offline. 

(Additionally the version will be sent as byte at start of the message. Might be implemented at a later point.)