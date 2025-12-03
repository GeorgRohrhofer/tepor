# Monitoring Service API
To get a shnapshot of the resource data of all nodes known to the Monitoring Server, a GET reqest can be sent to http://127.0.0.1:6943/monitor/all.

The data will be sent in json format looking like the following:

```json
{
    "123":{
        "MemoryUsage": 55.5,
        "CpuUsage": 44.5,
        "DiskUsage": 946.3,
        "NetworkUsage":[
            123.4,
            567.8
        ],
        "LastUpdated": "2025-12-02T22:11:30.6179651+01:00",
        "StillActive": true
    },
    "sdfghj":{
        "MemoryUsage": 55.5,
        "CpuUsage": 44.5,
        "DiskUsage": 946.3,
        "NetworkUsage":[
            123.4,
            567.8
        ],
        "LastUpdated": "2025-12-02T22:11:10.8843885+01:00",
        "StillActive": false
    }
}
```

An element starts with the node id (123) and then shows all the data from the moment of the request.

Clarifications:
- all numeric values are double format and in percentage (aside from network)
- NetworkUsage [rx/receive, tx/transmit] in bytes
- LastUpdated uses Server arrival time
- StillActive is true if the duration between the last two "heartbeats" is less than 12 seconds (3 times the usual duration - 4 seconds), and false if it is longer than that
