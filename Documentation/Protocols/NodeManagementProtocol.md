# NodeManagementProtocol.md (NMP)

# 1. Purpose

This document describes the binary client-server protocol used for TCP
communication between the management-server and the node-backend.\
Each message consists of a header (version, length) followed by a JSON
payload.

# 2. Message Format (Frame Layout)

Each message uses the following structure:

    +------------+----------------------+----------------------+
    | 1 Byte     | 4 Bytes             | N Bytes              |
    | VERSION    | LENGTH (uint32 BE)  | JSON PAYLOAD (UTF-8) |
    +------------+----------------------+----------------------+

## VERSION

-   1 byte\
-   Identifies the protocol version (current: `0x01`)

## LENGTH

-   4 bytes\
-   Unsigned 32-bit big-endian\
-   Specifies the length of the JSON payload in bytes

## JSON PAYLOAD

-   UTF-8 encoded JSON object\
-   Must follow the structure:

``` json
{
  "type": "command_name",
  "data": { ... }
}
```

# 3. Versioning

**Version 1 (`0x01`)**\
- JSON payload required\
- Supported commands:
  - HELOReq, HELOResp, QUIT, ERROR
  - ServerCreate, ServerStart, ServerStop, ServerRestart, ServerDelete, UpdateConfig
  - Sync, WorldSaved

# 4. Commands (Server → Client)

## HELOResp

``` json
{
  "type": "HELOReq",
  "data": {
    "active_id" : guid
  }
}
```

## ServerCreate

``` json
{
  "type": "ServerCreate",
  "data": {
    "config" : "string"
  }
}
```

## ServerStart

``` json
{
  "type": "ServerStart",
  "data": {
    "world_id" : "string"
  }
}
```

## ServerStop

``` json
{
  "type": "ServerStart",
  "data": {
    "world_id" : "string"
  }
}
```

## ServerRestart

``` json
{
  "type": "ServerStart",
  "data": {
    "world_id" : "string"
  }
}
```

## ServerDelete

``` json
{
  "type": "ServerDelete",
  "data": {
    "world_id" : "string"
  }
}

```
## quit

``` json
{
  "type": "QUIT"
}
```

## Unsupported Version

``` json
{
  "type": "VERSION_ERROR",
  "data": {
    "message" : "string",
    "current_version" : "string"
  }
}
```

# 5. Node Messages (Client → Server)

## HELOReq

``` json
{
  "type": "HELOReq",
  "data": {
    "previous_id" : guid
  }
}
```

## WorldSaved

``` json
{
  "type": "WorldSaved",
  "data": {
    "world_id" : "string",
    "hash" : "string"
  }
}
```

## ERROR

``` json
{
  "type": "ERROR",
  "data": {
    "message" : "string"
  }
}
```

# 6. Example Message (Hex + JSON)

JSON:

``` json
{"type":"QUIT"}
```

UTF‑8 length: 16 bytes\
Frame in hex:
    
    01 00 00 00 0F 7B 22 74 79 70 65 22 3A 22 51 55 49 54 22 7D


    
# 7. Changelog

### Version 1

-   Initial specification
