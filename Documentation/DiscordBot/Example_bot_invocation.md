# Example requests for discord bot invocation

In order for the bot application to connect to the discord API a Token is needed - a description to start the discord bot will be added as soon as concrete deployment plans are made.
## Sending a Message to a Server Channel

First the bot needs to be invited to the server. This can be done through this link:
https://discord.com/oauth2/authorize?client_id=1432009716015300640&permissions=2048&integration_type=0&scope=bot
(The bot only has the permission to send messages.)

To send a message to one or several servers, a POST request is sent to the given ip-address with port '6969' under '/message/send/channel'.

```
POST
to: 
http://127.0.0.1:6969/message/send/channel
```

The body contains a json object with "messageContent" defining the message that should be sent and "channels" are all the channels the massge should be sent to. 
Several channals can be seperated be a colon ',' ([1435700045620469780, 1278123451628856594, 1356368495739452271]).

```json
body:
{
  "messageContent":  "Your Message",
  "channels" : [1435700045620469780]
}
```


## Sending a Direct Message to a User

To send a message to one or several users, a POST request is sent to the given ip-address with port '6969' under '/message/send/direct'.

```
POST
to: 
http://127.0.0.1:6969/message/send/direct
```

The body contains a json object with "messageContent" defining the message that should be sent and "directs" are all the users the massge should be sent to. 
Several users can be seperated be a colon ',' ([497571859453213032, 583671859453213032, 1183553219784279170]).

```json
body:
{
  "messageContent":  "Your Message",
  "directs" : [497571859453213032]
}
```

In order to receive a message, a user needs to have private messages enabled. If they are disabled it can be seen in the output of the bot application.

